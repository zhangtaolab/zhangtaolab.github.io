---
phase: quick-260827-jvt
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - _pages/publications.md
  - papers/ref.bib
autonomous: true
requirements: [BIB-02]   # BIB-02 = this quick task's directive: remove the trailing DOI placeholder suffixes (publications.md) and the DOI field lines (ref.bib) from bao2026oryza + he2026trna, whose volume/issue info landed in quick task 260827-f7z; liao2026glycosylase and zheng2025larch placeholders stay until volume info exists

estimate:
  tokens: 12000
  raw_tokens: 12000
  tasks: 2
  confidence: low   # estimate-calibration: sample_count 0, factor 1 (not applied)

must_haves:
  truths:
    - "In `_pages/publications.md` the bao2026oryza entry line ends at `*Nature Communications* 2026, 17:6877.` — trailing DOI placeholder suffix deleted — while the title hyperlink targeting https://doi.org/10.1038/s41467-026-73769-8 earlier in the same line is retained (that href is what keeps ci-smoke assertion ② green)"
    - "In `_pages/publications.md` the he2026trna entry line ends at `*Trends in Biotechnology* 2026, 44(8):2446&ndash;2471.` — trailing DOI placeholder suffix deleted — title hyperlink targeting https://doi.org/10.1016/j.tibtech.2026.02.016 retained"
    - "The liao2026glycosylase (Science Bulletin, still no volume) and zheng2025larch (HPJ, still no volume) entries are untouched: trailing `DOI:` suffixes remain in publications.md and their DOI fields remain in ref.bib"
    - "In `papers/ref.bib` the bao2026oryza and he2026trna entries carry no DOI field and end with `  year={2026}` (no trailing comma) before the closing brace, matching the complete-entry convention (wang2026maize / liu2025pdllms / yang2025rice); `grep -c '^@' papers/ref.bib` stays 12 and `grep -c 'doi={' papers/ref.bib` drops 4 → 2"
    - "The live serve page http://127.0.0.1:4000/publications/ (jekyll serve --livereload running at plan time; edit-to-render observed ≤10s in Phase 1 probes) shows: zero occurrences of either removed suffix text, both doi.org title hrefs present, the Science Bulletin trailing placeholder present exactly once"
    - "`bash scripts/validate.sh` exits 0 and `bash scripts/ci-smoke.sh _site` prints its PASS line"
    - "One `fix(quick/bib-02)` commit lands both files locally and is NOT pushed — DEPLOY_ENABLED is live, so a push to main auto-deploys production zhangtaolab.org; push timing belongs to the user/orchestrator"
  artifacts:
    - "_pages/publications.md: exactly 2 lines changed (one per entry, line-shortening only), no other line touched"
    - "papers/ref.bib: exactly the two DOI field lines removed plus year-line comma normalization; 12 top-level entries intact"
  key_links:
    - "_pages/publications.md edit → jekyll serve --livereload regen → http://127.0.0.1:4000/publications/ plain-text render → curl occurrence-count assertions (planner-verified: trailing placeholders render as plain text, NOT autolinks; title links render as <a href=\"https://doi.org/...\">)"
    - "retained title href `s41467-026-73769-8` in _site/publications/index.html → scripts/ci-smoke.sh assertion ② → deploy.yml push gate"
    - "papers/ref.bib → jekyll-scholar (`scholar.source: /papers/`, bibliography ref.bib) → sole consumer is _pages/talks.md `@incollection` queries (permanently empty: 0 @incollection entries among the 12) — the DOI field removal changes no rendered surface"
    - "papers/ref.bib → scripts/validate.rb BibTeX layer (parse + required fields + key uniqueness; DOI is not a required field — Phase 3 baseline passed with 8/12 doi-less entries) + D-08 HEAD-vs-worktree entry-count guard (12 = 12, stays silent)"
---

<objective>
Quick task 260827-f7z landed volume/issue info for two 2026 papers (bao2026oryza: *Nature Communications* 17:6877; he2026trna: *Trends in Biotechnology* 44(8):2446–2471), but both still carry the trailing `DOI: URL` placeholder that this site uses ONLY while volume info is pending. Remove the placeholders from both surfaces:

1. `_pages/publications.md` (hand-curated markdown — the publications page does NOT render from ref.bib): delete the trailing DOI suffix from the bao2026oryza line (currently line 20) and the he2026trna line (currently line 24). KEEP the `[title](https://doi.org/...)` hyperlinks — `scripts/ci-smoke.sh` assertion ② greps the substring `s41467-026-73769-8` in `_site/publications/index.html`, and the retained href satisfies it. Convention proof from the page itself: entries WITH volume info end at the journal citation with no trailing suffix (*Advanced Science* `2026:e23401.`, *Plant Physiology* `2025, 197(1):kiae557.`).
2. `papers/ref.bib`: drop the DOI field line from both entries, matching the file convention for complete entries (liu2025pdllms / yang2025rice carry no doi field; their last field has no trailing comma).

Explicitly OUT of scope: `liao2026glycosylase` (Science Bulletin, still no volume) and `zheng2025larch` (HPJ, still no volume) keep their DOI placeholders in BOTH files.

Purpose: the two completed references match the site's own convention for finished entries.
Output: two-file edit, live-page + validator + smoke proof battery, one local commit (no push).
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md

# Both files this task touches (read each once before editing — Edit requires prior Read)
@papers/ref.bib

# Proof tooling (validate.sh is a 4-line exec wrapper; ci-smoke.sh anchor ② targets bao2026oryza's DOI)
@scripts/validate.sh
@scripts/ci-smoke.sh

# Planner-verified current state (commit e0978bf5, clean tree, 2026-08-27):
#
# publications.md line 20 (bao2026oryza) — current full line:
#   1. Bao Y, You HL, Liu S, Liu GQ, Wu YC, Yang QQ, You Q, Liu P, Yi CD\*, Zhang WL\*, Cheng ZK\*, **Zhang T\***. [Telomere-to-telomere genome assembly of *Oryza australiensis* reveals transposon-driven centromere repositioning and shared EE&ndash;DD ancestry](https://doi.org/10.1038/s41467-026-73769-8). *Nature Communications* 2026, 17:6877. DOI: https://doi.org/10.1038/s41467-026-73769-8.
#   → delete the final ` DOI: https://doi.org/10.1038/s41467-026-73769-8.` (leading space through period); line must end at `17:6877.`
#
# publications.md line 24 (he2026trna) — current line tail:
#   ...[Harnessing diverse tRNAs and AI-guided mining for compact and efficient plant multiplex genome editing](https://doi.org/10.1016/j.tibtech.2026.02.016). *Trends in Biotechnology* 2026, 44(8):2446&ndash;2471. DOI: https://doi.org/10.1016/j.tibtech.2026.02.016.
#   → delete the final ` DOI: https://doi.org/10.1016/j.tibtech.2026.02.016.`; line must end at `44(8):2446&ndash;2471.` (`&ndash;` is a literal 8-char HTML entity in the source)
#
# - Edit anchors are unique: `17:6877` occurs exactly once in publications.md; `44(8):2446` occurs exactly once
# - Line 22 (liao2026glycosylase, Science Bulletin) and line 30 (zheng2025larch, HPJ) keep their trailing DOI placeholders — volume info still pending
# - Rendered shape (planner grep of current _site + live page): trailing placeholders render as PLAIN TEXT `DOI: https://…` (no autolink); title links render as <a href="https://doi.org/10.1038/s41467-026-73769-8">Telomere-to-telomere…</a>
# - jekyll serve --livereload is RUNNING (live page 200 at plan time); _site is fresh post-f7z (contains `17:6877` and `44(8):2446`)
# - ref.bib: 12 @article entries; exactly 4 DOI field lines today — bao2026oryza (line 10), liao2026glycosylase (line 18), he2026trna (line 29), zheng2025larch (line 45). Complete-entry convention: last field before `}` has NO trailing comma (wang2026maize line 37 `  year={2026}`)
# - ref.bib's only consumer is _pages/talks.md `@incollection` queries — both permanently empty (0 @incollection entries), so the DOI field removal changes no rendered page
# - f7z commits (5105c8d1, 8df20a2f, e0978bf5) are local-only; origin/main is behind — nothing in this task pushes
</context>

<tasks>

<task type="tracer">
  <name>End-to-end: remove both trailing DOI placeholders in publications.md and prove them gone on the live serve page</name>
  <files>_pages/publications.md</files>
  <precondition>`curl -sf http://127.0.0.1:4000/publications/` returns 200 (serve running at plan time). If it does not, run `bundle exec jekyll build` and perform the same occurrence-count assertions against `_site/publications/index.html` instead of the live URL.</precondition>
  <action>
  Read `_pages/publications.md` first (Edit requires prior Read). Exactly two line-shortening edits — the current full line contents are quoted in the context section above:
  (1) bao2026oryza entry (currently line 20): the anchor `17:6877.` occurs exactly once in the file. Delete everything from the single space AFTER `17:6877.` to the end of line — that segment is the placeholder suffix: the literal label `DOI:` with a space on each side, the doi.org URL (identical to this line's title-hyperlink target), and the terminating period. The line must end at `...*Nature Communications* 2026, 17:6877.`.
  (2) he2026trna entry (currently line 24): same operation anchored on `44(8):2446&ndash;2471.` (occurs exactly once; the `&ndash;` is a literal HTML entity in the markdown source, not a character). The line must end at `...*Trends in Biotechnology* 2026, 44(8):2446&ndash;2471.`.
  Do NOT touch any other line — in particular the liao2026glycosylase line (currently line 22, Science Bulletin, no volume yet) and the zheng2025larch line (currently line 30, HPJ, no volume yet) keep their trailing placeholders: the suffix convention exists only while volume info is pending. Do NOT alter the title hyperlinks `[...](https://doi.org/...)` — ci-smoke assertion ② depends on the bao2026oryza href surviving this edit.
  Then let livereload regenerate (edit-to-render observed ≤10s; the verify below polls up to 30s) and prove the change on the live page before moving on.
  </action>
  <verify>
    <automated>for i in $(seq 1 15); do curl -sf http://127.0.0.1:4000/publications/ | grep -q 'DOI: https://doi.org/10.1038/s41467-026-73769-8' || break; sleep 2; done; H=$(curl -sf http://127.0.0.1:4000/publications/) && [ "$(printf '%s' "$H" | grep -o 'DOI: https://doi\.org/10\.1038/s41467-026-73769-8' | wc -l | tr -d ' ')" = "0" ] && [ "$(printf '%s' "$H" | grep -o 'DOI: https://doi\.org/10\.1016/j\.tibtech\.2026\.02\.016' | wc -l | tr -d ' ')" = "0" ] && [ "$(printf '%s' "$H" | grep -o 'href="https://doi.org/10.1038/s41467-026-73769-8"' | wc -l | tr -d ' ')" -ge 1 ] && [ "$(printf '%s' "$H" | grep -o 'href="https://doi.org/10.1016/j.tibtech.2026.02.016"' | wc -l | tr -d ' ')" -ge 1 ] && [ "$(printf '%s' "$H" | grep -o 'DOI: https://doi\.org/10\.1016/j\.scib\.2026\.05\.046' | wc -l | tr -d ' ')" = "1" ] && printf '%s' "$H" | grep -q '17:6877' && printf '%s' "$H" | grep -q '44(8):2446' && [ "$(git diff -U0 -- _pages/publications.md | grep -c '^-[^-]')" = "2" ] && [ "$(git diff -U0 -- _pages/publications.md | grep -c '^+[^-]')" = "2" ] && echo LIVE-PAGE-OK</automated>
  </verify>
  <done>
  Live page battery green: both removed-suffix texts occur 0 times; both doi.org title hrefs occur ≥1 (bao href keeps ci-smoke anchor ② satisfiable); Science Bulletin placeholder occurs exactly once; volume renders `17:6877` / `44(8):2446` intact; `git diff -U0` shows exactly 2 removed and 2 added lines in publications.md (line shortenings only).
  </done>
</task>

<task type="auto">
  <name>ref.bib DOI field removal + validator/smoke battery + single local commit — no push</name>
  <files>papers/ref.bib</files>
  <action>
  Read `papers/ref.bib` first (Edit requires prior Read). Exactly two three-line-block replacements:
  For each of the entries `bao2026oryza` (block currently lines 3–11) and `he2026trna` (block currently lines 21–30): match the three-line run consisting of (a) the `  year={2026},` line, (b) the entry's final field line — the DOI URL inside braces, and (c) the closing `}` line; replace it with the two-line run `  year={2026}` then `}`. The trailing comma on the year line MUST be removed with it: this file's complete entries end with a comma-less last field before the closing brace (cf. wang2026maize `  year={2026}`, liu2025pdllms `  year={2025}`), and leaving the comma would create the file's only dangling comma. Each three-line old-string is unique because the DOI line differs per entry.
  Do NOT touch `liao2026glycosylase` (Science Bulletin — no volume yet) or `zheng2025larch` (HPJ — no volume yet): their DOI field lines stay. Do not add, remove, or reorder any other field or entry — top-level entry count stays 12.
  Then the proof battery and commit (one commit carries this file AND the Task 1 publications.md edit — same logical change):
  (1) `bash scripts/validate.sh` must exit 0 — BibTeX parse + required fields + key uniqueness; DOI is not a required field (Phase 3 baseline passed with 8/12 doi-less entries). The D-08 workspace-count guard compares HEAD vs worktree entry counts: 12 = 12, so it stays silent by design.
  (2) `bash scripts/ci-smoke.sh _site` must print its PASS line — assertion ② stays green via the retained title href; sitemap/feed/vendor tripwires unaffected. The serve process already regenerated `_site` after the Task 1 edit; the ref.bib edit changes no rendered surface (ref.bib's only consumer is the permanently-empty @incollection queries on /talks/), so no extra regen wait is needed. If you fell back to `jekyll build` in Task 1, the build output is already current.
  (3) Commit exactly the two files with the established message convention: `fix(quick/bib-02): remove DOI placeholders from bao2026oryza + he2026trna (volume info present)`. Do NOT push in any form — DEPLOY_ENABLED is live, so a push to main auto-deploys production zhangtaolab.org; push timing belongs to the user/orchestrator.
  </action>
  <verify>
    <automated>B=$(sed -n '/@article{bao2026oryza,/,/^}/p' papers/ref.bib) && H=$(sed -n '/@article{he2026trna,/,/^}/p' papers/ref.bib) && L=$(sed -n '/@article{liao2026glycosylase,/,/^}/p' papers/ref.bib) && Z=$(sed -n '/@article{zheng2025larch,/,/^}/p' papers/ref.bib) && [ "$(printf '%s\n' "$B" | grep -c 'doi=')" = "0" ] && printf '%s\n' "$B" | grep -q '^  year={2026}$' && [ "$(printf '%s\n' "$H" | grep -c 'doi=')" = "0" ] && printf '%s\n' "$H" | grep -q '^  year={2026}$' && printf '%s\n' "$L" | grep -q 'scib\.2026\.05\.046' && printf '%s\n' "$Z" | grep -q 'hpj\.2025\.02\.020' && [ "$(grep -c '^@' papers/ref.bib)" = "12" ] && [ "$(grep -c 'doi={' papers/ref.bib)" = "2" ] && bash scripts/validate.sh && bash scripts/ci-smoke.sh _site && [ "$(git diff --name-only HEAD~1 HEAD | sort | tr '\n' ' ')" = "_pages/publications.md papers/ref.bib " ] && git log origin/main..HEAD --oneline | grep -q 'bib-02' && echo BIB-02-OK</automated>
  </verify>
  <done>
  Both edited bib entries end at the comma-less `  year={2026}` with no DOI field line; liao2026glycosylase and zheng2025larch DOI fields intact; 12 top-level entries; exactly 2 remaining DOI lines file-wide (scib + hpj); validate.sh exit 0; ci-smoke.sh _site prints PASS; one `fix(quick/bib-02)` commit touches exactly the two files and sits local-only (present in origin/main..HEAD ahead-set).
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| (none new) | Data-only deletion of two trailing text suffixes and two bibliography field lines; no user input, no runtime code, no dependency changes |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-quick-01 | Tampering | wrong-occurrence edit (title hyperlink instead of trailing suffix) or scope creep into liao2026glycosylase/zheng2025larch lines | low | mitigate | Edit anchors (`17:6877.`, `44(8):2446&ndash;2471.`) each occur exactly once (planner-verified); verify battery proves shape: removed-suffix occurrences 0, title hrefs ≥1, Science Bulletin placeholder exactly 1, ref.bib DOI line count exactly 2, diff touches exactly 2 lines in publications.md |
| T-quick-02 | Denial of Service | production deploy via unintended push | medium | mitigate | Executor never invokes git push; DEPLOY_ENABLED gate is live so push to main auto-deploys zhangtaolab.org. Commit stays local; Task 2 verify asserts the commit sits in the origin/main..HEAD ahead-set |
</threat_model>

<verification>
1. Live serve page occurrence battery (Task 1): both trailing DOI suffix texts gone, both doi.org title hrefs present, Science Bulletin placeholder present exactly once, volume info renders untouched.
2. `bash scripts/validate.sh` exits 0 — the identical validator runs in CI (deploy.yml Validate content step, pre-build), so a local pass guarantees the later push will not be blocked.
3. `bash scripts/ci-smoke.sh _site` prints PASS — assertion ② satisfied by the retained bao2026oryza title href; sitemap ≥10, feed.xml valid, no vendor leak.
4. ref.bib shape: 12 top-level entries, exactly 2 remaining DOI field lines (scib + hpj), both edited entries end with comma-less `year={2026}`.
5. Exactly one commit touching exactly `_pages/publications.md` + `papers/ref.bib`, local only, nothing pushed.
</verification>

<success_criteria>
- bao2026oryza entry line ends `*Nature Communications* 2026, 17:6877.` and he2026trna entry line ends `*Trends in Biotechnology* 2026, 44(8):2446&ndash;2471.` — no trailing DOI suffixes; title hyperlinks retained
- liao2026glycosylase and zheng2025larch placeholders untouched in BOTH files (volume info still pending for both)
- ref.bib: no DOI fields on the two edited entries, comma-less last-field endings, 12 entries intact
- Live-page battery + validate.sh + ci-smoke.sh all green; one local `fix(quick/bib-02)` commit, not pushed
</success_criteria>

<output>
Create `.planning/quick/260827-jvt-remove-doi-placeholders-from-two-entries/260827-jvt-SUMMARY.md` when done
</output>
