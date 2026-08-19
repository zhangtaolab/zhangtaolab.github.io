#!/usr/bin/env ruby
# pub-extract.rb — D-18 publication-by-publication audit extractor (Plan 02-03 Task 1)
#
# Parses BOTH sides with the same rules so the two lists are comparable:
#   new side: _site/publications/index.html   (built output of hand-written _pages/publications.md)
#   old side: .planning/phases/02-auto-deploy/old-site-publication.html (byte archive of live /Publication)
#
# Both pages share the DOM shape: <h2 id="YYYY">YYYY</h2> year buckets, each followed
# by a list (<ol> new / <ul> old) of <li> entries. Entry text format (both sides):
#   AUTHORS. [TITLE](link). JOURNAL ...
#
# The old site additionally NESTS some <li> sub-entries ("Commentary: ..." companion
# articles) inside a parent <li> via a nested <ul>. Parsing is therefore depth-aware:
#   depth 1 li  = publication entry       → pub-extract-<side>.txt
#   depth >= 2  = sub-entry (annotation of its parent) → <side>-subentries.txt
# The new site has no nested lists; both files are still emitted for symmetry.
#
# Title rule: first <a> content when the entry has a link; otherwise the last
# sentence before the JOURNAL <em> (the journal italic is the LAST <em> in the entry,
# because titles may themselves contain <em> segments — species names, "*De Novo*").
# First author = first name-initials token group of the pre-title text.
#
# Output line format: YEAR | normalized-title | first-author | raw-title
#   normalized-title = tags stripped, HTML entities decoded, downcased,
#                      all non-alphanumerics removed, whitespace squeezed out
#
# Usage: ruby pub-extract.rb <new|old>
#   new → reads _site/publications/index.html, writes pub-extract-new.txt
#   old → reads old-site-publication.html,     writes pub-extract-old.txt

require "cgi"

SIDE = ARGV[0]
unless %w[new old].include?(SIDE)
  warn "usage: ruby pub-extract.rb <new|old>"
  exit 1
end

ROOT = File.expand_path(__dir__ + "/../../..")
SRC =
  if SIDE == "new"
    File.join(ROOT, "_site/publications/index.html")
  else
    File.join(__dir__, "old-site-publication.html")
  end
OUT        = File.join(__dir__, "pub-extract-#{SIDE}.txt")
OUT_SUB    = File.join(__dir__, "pub-extract-#{SIDE}-subentries.txt")

html = File.read(SRC, encoding: "UTF-8")

# --- locate year buckets ------------------------------------------------------
# buckets[i] = [year, h2_end_offset, region_end_offset]
# region for bucket i spans [h2_end_i, start of next year h2) or EOF for the last one.
h2_re = /<h2[^>]*>\s*((?:19|20)\d{2})\s*<\/h2>/
buckets = []
matches = []
html.scan(h2_re) { matches << Regexp.last_match }
abort "no year buckets found" if matches.empty?
matches.each_with_index do |m, i|
  buckets << [m[1], m.end(0), matches[i + 1] ? matches[i + 1].begin(0) : html.length]
end

# --- depth-aware list parsing -------------------------------------------------
# Returns a flat list of [depth, content, span_begin, span_end] for every <li> in
# the region, where depth counts list nesting (1 = the year's outermost list,
# 2+ = nested sub-lists) and the span covers the li's inner content. Spans allow
# a sub-entry to be parented to the depth-1 item whose range ENCLOSES it (a stack
# emits nested items before their parent, so "most recent depth-1 item" is wrong).
# Uses String#match + MatchData#begin/#end (character offsets) — NOT StringScanner,
# whose #pos is a byte offset and drifts against String#[] ranges on multibyte
# content († – ′ ’ α appear throughout the corpus).
LIST_TOK = /<\/?ul[^>]*>|<\/?ol[^>]*>|<li[^>]*>|<\/li>/
def list_items(region)
  depth = 0
  stack = [] # [depth_at_open, content_start_offset]
  items = []
  pos = 0
  while (m = region.match(LIST_TOK, pos))
    tok = m[0]
    case tok
    when /\A<(?:ul|ol)/ then depth += 1
    when %r{\A</(?:ul|ol)} then depth -= 1
    when /\A<li/ then stack << [depth, m.end(0)]
    when %r{\A</li>}
      d, start = stack.pop
      items << [d, region[start...m.begin(0)], start, m.begin(0)] if d
    end
    pos = m.end(0)
  end
  items
end

# --- entry field extraction ---------------------------------------------------
def strip_tags(s)
  s.gsub(/<[^>]*>/, " ")
end

def clean(s)
  CGI.unescapeHTML(s.to_s).gsub(/\s+/, " ").strip
end

def normalize(s)
  clean(s).downcase.gsub(/[^a-z0-9]/, "")
end

def first_author(pre_text)
  t = clean(strip_tags(pre_text))
  m = t.match(/\A[^\p{L}]*(?:and\s+)?(\p{Lu}[\p{L}'’\-]*\s+\p{Lu}[\p{L}.]*)/)
  m ? m[1] : ""
end

# content: full li inner HTML (may contain a nested sub-list at the end)
def parse_entry(content)
  own = content.split(/<(ul|ol)[\s>]/).first || content # strip trailing sub-list
  title_raw = nil
  if (am = own.match(/<a[^>]*>(.*?)<\/a>/m))
    title_raw = clean(strip_tags(am[1]))
    pre_title = own[0...am.begin(0)]
  else
    em_idx = own.rindex(/<em[\s>]/)
    head = em_idx ? own[0...em_idx] : own
    text = clean(strip_tags(head))
    parts = text.split(/\.\s+/).reject { |p| p.strip.empty? }
    title_raw = parts.last.to_s
    pre_title = parts[0...-1].join(". ") + (parts.length > 1 ? ". " : "")
  end
  [normalize(title_raw), first_author(pre_title), title_raw]
end

entries = []     # [year, norm, first_author, raw]
subentries = []  # [year, parent_raw, sub_raw]
buckets.each do |year, from, to|
  items = list_items(html[from...to])
  tops = items.select { |(d, *_)| d <= 1 }
  tops.each do |(depth, content, _b, _e)|
    norm, fa, raw = parse_entry(content)
    entries << [year, norm, fa, raw]
  end
  items.each do |(depth, content, begin_span, end_span)|
    next unless depth > 1
    # parent = the depth-1 item whose span encloses this sub-entry's span
    parent = tops.find { |(_d, _c, tb, te)| tb < begin_span && end_span < te }
    _n, _f, sraw = parse_entry(content)
    subentries << [year, parent ? parse_entry(parent[1])[2] : "(parent not identified)", sraw]
  end
end

File.open(OUT, "w") do |f|
  entries.each { |(y, n, a, r)| f.puts "#{y} | #{n} | #{a} | #{r}" }
end
File.open(OUT_SUB, "w") do |f|
  subentries.each { |(y, p, r)| f.puts "#{y} | SUB of: #{p} | #{r}" }
end

years = entries.map(&:first).uniq.sort
warn "#{SIDE}: entries=#{entries.size} year-buckets=#{years.size} (#{years.first}..#{years.last}) sub-entries=#{subentries.size}"
empty_norm = entries.count { |e| e[1].empty? }
empty_fa   = entries.count { |e| e[2].empty? }
warn "#{SIDE}: empty normalized-title=#{empty_norm} empty first-author=#{empty_fa} (must all be 0)"
entries.each_with_index { |e, i| warn "  ##{i + 1} EMPTY norm: #{e[3][0, 70]}" if e[1].empty? }
entries.each_with_index { |e, i| warn "  ##{i + 1} EMPTY author: #{e[3][0, 70]}" if e[2].empty? }
# link-as-title suspicion: a "title" that looks like a bare URL / DOI / PDF path
entries.each_with_index do |e, i|
  warn "  ##{i + 1} SUSPICIOUS title: #{e[3][0, 70]}" if e[3] =~ /\Ahttps?:|\Adoi\b|\A\/|\.pdf\z/i
end
# per-year counts (for the audit report's breakdown table)
by_year = Hash.new(0)
entries.each { |e| by_year[e[0]] += 1 }
warn "#{SIDE}: per-year: " + by_year.keys.sort.map { |y| "#{y}=#{by_year[y]}" }.join(" ")
