---
phase: 03-content-validation
reviewed: 2026-08-20T03:59:22Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - .github/workflows/deploy.yml
  - scripts/validate.rb
  - scripts/validate.sh
findings:
  critical: 2
  warning: 2
  info: 3
  total: 7
status: issues_found
---

# Phase 03: Code Review Report

**Reviewed:** 2026-08-20T03:59:22Z
**Depth:** standard
**Files Reviewed:** 3 (.github/workflows/deploy.yml +2, scripts/validate.rb new, scripts/validate.sh new)
**Status:** issues_found

## Summary

Reviewed the Phase 3 content-validation deliverables: `scripts/validate.rb` (YAML syntax+schema validation, BibTeX parse/required-field/key-uniqueness checks, D-08 git-based entry-count reminder), `scripts/validate.sh` (wrapper), and the 2-line `Validate content` step in `deploy.yml`.

**What works (verified empirically, not just by reading):** baseline run passes (`PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一`, exit 0); YAML syntax errors produce the designed Chinese message with line/column while other files continue; duplicate bib keys are caught via the raw-regex tally; truncated (unclosed-brace) bib entries hit the empty-key placeholder path; the D-08 reminder fires on count change (12→13), stays silent when unchanged, and never affects the exit code; FAIL exits 1, blocking the CI build job. The bibtex-ruby 6.2.0 API shape assumptions (`entry[:bibtex_key]`, `entry[field]`, `bib.to_a`, `bib.length`) all check out against the locked gem. Schema assumptions match the actual data files.

**Key concerns:** the validator crashes with raw English backtraces on two plausible maintainer-mistake inputs it was explicitly built to survive — an emptied/whitespace-only YAML file (returns `false` from `Psych.parse_file`, then `NoMethodError` on `.to_ruby`) and a non-UTF-8 (e.g., GBK-saved) or missing `ref.bib` (`ArgumentError` / `Errno::ENOENT`). Both crashes abort the entire run, masking every other file's errors, in direct violation of the script's own design contract (collect-all / 中文报出 / T-03-03 兜底). Additionally, `Psych.parse_file(...).to_ruby` is the unsafe deserialization path despite the comment claiming otherwise.

## Narrative Findings (AI reviewer)

All findings below were confirmed by execution against Ruby 4.0.6 / psych 5.3.1 / bibtex-ruby 6.2.0 (the locked versions) in a sandbox copy — not inferred from reading alone.

### CR-01: Empty or whitespace-only YAML data file crashes the script and masks all other validation

**File:** `scripts/validate.rb:35-38`
**Issue:** `Psych.parse_file(path)` returns `false` (not a `Nodes::Document`) for an empty or whitespace-only file. `false.to_ruby` raises `NoMethodError`, which the rescue (only `Psych::SyntaxError`) does not catch. Verified:

```text
$ : > _data/news.yml && bundle exec ruby scripts/validate.rb
scripts/validate.rb:35:in 'block in <main>': undefined method 'to_ruby' for false (NoMethodError)
```

The same rescue also misses `Errno::ENOENT` when a data file is deleted/renamed (verified). The crash occurs on the first file processed, so **zero** other YAML files, the BibTeX checks, and the summary line ever run — exactly the "掩盖其余文件的错误" (masking other files' errors) failure mode the script's T-03-03 fallback was designed to prevent. An emptied `_data/*.yml` (bad merge-conflict resolution, accidental save) is a top-probability maintainer mistake this validator exists to catch. It does exit non-zero, so CI still fails closed, but the local maintainer gets an English backtrace instead of the designed Chinese message, with no diagnosis of the other files. Violates the file's own header contract: "全部错误一次收集、中文报出".

**Fix:** Handle the non-Document return and broaden the rescue; the structure layer already handles `nil`/`false` data gracefully (`data.is_a?(Array)` check emits "顶层结构应为列表，当前是 NilClass"):

```ruby
begin
  doc = Psych.parse_file(path)
  parsed[label] = doc.respond_to?(:to_ruby) ? doc.to_ruby : nil
rescue Psych::SyntaxError => e
  errors << "#{File.basename(path)} 第 #{e.line} 行第 #{e.column} 列：YAML 语法错误（#{e.problem}）"
rescue Errno::ENOENT
  errors << "#{File.basename(path)}：文件不存在——请勿删除或改名数据文件"
rescue StandardError => e
  errors << "#{File.basename(path)} 读取异常（#{e.class}）：#{e.message[0, 80]}——请人工检查该文件"
end
```

(Preferably combined with the WR-02 `safe_load` fix, which returns `nil` for empty files and eliminates the `false` case entirely.)

### CR-02: ref.bib with invalid UTF-8 bytes (or missing) crashes with uncaught ArgumentError/ENOENT

**File:** `scripts/validate.rb:131-134`
**Issue:** The rescue only covers `BibTeX::ParseError`. Two verified crash inputs bypass it:

1. A `ref.bib` saved in a non-UTF-8 encoding (e.g., GBK — a realistic accident for a Chinese-language lab, e.g., pasting a Chinese note or an author name saved by a GBK-default editor):

```text
bibtex-ruby-6.2.0/lib/bibtex/utilities.rb:33:in 'BibTeX.parse': invalid byte sequence in UTF-8 (ArgumentError)
	from scripts/validate.rb:131:in '<main>'
```

2. A missing `papers/ref.bib` (repo restructure): `File.read` at line 131 raises `Errno::ENOENT` before the rescue's class matches (same crash shape as the YAML ENOENT in CR-01).

In both cases the script dies with an English backtrace, skipping the required-field layer, the key-uniqueness layer, and the D-08 reminder — again violating the collect-all/no-crash design contract.

**Fix:** Broaden the rescue and validate encoding up front:

```ruby
bib = nil
begin
  raw = File.read(BIB_PATH)
  unless raw.valid_encoding?
    errors << "#{BIB_PATH} 含非 UTF-8 字节（多为编辑器以 GBK 等编码保存）——请以 UTF-8 重新保存"
  else
    bib = BibTeX.parse(raw)
  end
rescue BibTeX::ParseError => e
  errors << "#{BIB_PATH} 解析失败（检查最近编辑：多为缺失逗号或未闭合大括号）—— #{e.message[0, 120]}"
rescue Errno::ENOENT
  errors << "#{BIB_PATH}：文件不存在——请勿删除或改名"
rescue StandardError => e
  errors << "#{BIB_PATH} 解析异常（#{e.class}）：#{e.message[0, 80]}——请人工检查"
end
```

(Reading once into `raw` also removes the triple file read — see IN-02.)

### WR-01: CWD-relative data paths crash validate.sh when invoked from any subdirectory

**File:** `scripts/validate.rb:15-22,35` and `scripts/validate.sh:3`
**Issue:** `validate.sh` resolves the Ruby script location-independently (`"$(dirname "$0")/validate.rb"`), advertising that it can be run from anywhere, and `bundle exec` happily finds the Gemfile from subdirectories. But `validate.rb` reads all inputs relative to the process CWD (`_data/news.yml`, `papers/ref.bib`). Running `bash ../scripts/validate.sh` from any subdirectory (verified) crashes at line 35 with the raw `Errno::ENOENT` backtrace from CR-01 — before the Chinese error machinery ever engages. CI is unaffected (steps default to the workspace root); this is a local-maintainer trap that contradicts the wrapper's portability signal.

**Fix:** Anchor all paths to the script location. In `validate.rb`:

```ruby
ROOT = File.expand_path("..", __dir__)
YAML_FILES = {
  "news"   => File.join(ROOT, "_data/news.yml"),
  # ... likewise for the other four
}.freeze
BIB_PATH = File.join(ROOT, "papers/ref.bib")
```

and in `validate.sh` either keep `exec bundle exec ruby "$(dirname "$0")/validate.rb" "$@"` (paths now self-anchored) or add `cd "$(dirname "$0")/.."` before `exec`. Note the git-based D-08 layer at lines 179-191 must also run from the repo root for `git show HEAD:papers/ref.bib` to resolve — anchoring with `__dir__` fixes both at once.

### WR-02: Unsafe YAML deserialization path used despite comment claiming otherwise

**File:** `scripts/validate.rb:29-30,35`
**Issue:** The comment states "不使用对象反序列化式加载入口" (not using the object-deserialization loading entry), but `Psych.parse_file(...).to_ruby` invokes the full `Psych::Visitors::ToRuby` visitor — the deserialization path. A YAML file containing `!ruby/object:` tags would instantiate arbitrary Ruby objects when the validator runs. Threat model: repo files are maintainer-authored, but a malicious PR combined with a maintainer running `scripts/validate.sh` locally (the advertised workflow) means arbitrary code execution on the maintainer's machine. It also makes the "与 Jekyll 数据读取同路" claim inaccurate — Jekyll loads data files with safe loading semantics, not `to_ruby`.

**Fix:** Use `Psych.safe_load(File.read(path))`. Verified compatible with all five current data files (all parse identically as Arrays with correct lengths) and it returns `nil` — not `false`, no crash — for empty files, which also structurally eliminates half of CR-01:

```ruby
parsed[label] = Psych.safe_load(File.read(path))
```

`Psych::SyntaxError` and `Errno::ENOENT` still need the CR-01 rescue; syntax errors keep their line/column through `safe_load`.

### IN-01: Key-tally and entry-count regexes are mutually inconsistent and both miss `@type {key,` spacing

**File:** `scripts/validate.rb:159,174-176`
**Issue:** Line 159 scans with unanchored `@\w+\{([^,\s]+)\s*,` while line 175 counts with line-anchored `^@[a-zA-Z]+\{`. They disagree on mid-line openers and underscored types, and both miss an opener written with whitespace before the brace (`@article {key,`), which bibtex-ruby accepts — a duplicate written in that style would evade the uniqueness check while still being silently renamed by the parser. Current `ref.bib` is uniformly `@article{key,` so this is latent, not active.

**Fix:** Harmonize both on one pattern, e.g. `text.scan(/@\s*[a-zA-Z]\w*\s*\{([^,\s]+)\s*,/)` for the key tally and the same opener portion for `bib_entry_count`.

### IN-02: ref.bib read from disk three times per run

**File:** `scripts/validate.rb:131,159,186`
**Issue:** `File.read(BIB_PATH)` is executed at line 131 (parse), line 159 (key scan), and line 186 (work-tree count). Harmless at current size, but the three reads can diverge if the file changes mid-run, and it is avoidable repetition.

**Fix:** Read once into a local (as in the CR-02 fix) and reuse for the parse, the key scan, and the work-tree count.

### IN-03: Dead initialization of `counts`

**File:** `scripts/validate.rb:26,40`
**Issue:** `counts = {}` at line 26 is unconditionally overwritten at line 40 before any read; the initializer is dead code that suggests a partial-failure path that does not exist.

**Fix:** Delete line 26, or make line 40 defensive (`counts = parsed.transform_values { ... }` with a fallback for unparsed files) so the PASS summary cannot reference nil counts if the file-failure handling changes.

---

_Reviewed: 2026-08-20T03:59:22Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
