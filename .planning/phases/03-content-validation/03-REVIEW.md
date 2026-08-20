---
phase: 03-content-validation
reviewed: 2026-08-20T07:43:19Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - .github/workflows/deploy.yml
  - scripts/validate.rb
  - scripts/validate.sh
findings:
  critical: 0
  warning: 2
  info: 2
  total: 4
status: issues_found
---

# Phase 03: Code Review Report

**Reviewed:** 2026-08-20T07:43:19Z
**Depth:** standard
**Files Reviewed:** 3 (.github/workflows/deploy.yml +2 lines, scripts/validate.rb new, scripts/validate.sh new)
**Status:** issues_found

## Summary

Re-review after gap-closure commits `e28e6aa4` and `4bd8f987`. All findings were verified by execution against the locked stack (Ruby 4.0.6 / psych 5.3.1 / bibtex-ruby 6.2.0) — baseline in the real repo, crash/degenerate inputs in a disposable clone under `/tmp`. No source files were modified; the sandbox clone has been deleted.

### Prior-round fix verification (all 7 confirmed fixed)

| Prior ID | Claimed fix | Verified how | Verdict |
|---|---|---|---|
| CR-01 | Empty/missing yml no longer crashes; collect-all preserved | `: > _data/news.yml` + `rm _data/pi.yml` simultaneously → both Chinese errors (`文件不存在` / `顶层结构应为列表…当前是 NilClass`), `FAIL: 2 个问题`, exit 1, no backtrace | FIXED |
| CR-02 | GBK/missing bib no longer crashes | GBK-byte bib → `含非 UTF-8 字节（多为编辑器以 GBK 等编码保存）`; missing bib → `文件不存在`; both alongside the YAML errors, exit 1 | FIXED |
| WR-01 | `__dir__`-anchored ROOT | Ran from `_data/` (direct) and `papers/` (via `validate.sh` wrapper) → identical PASS; D-08 git guard also fires correctly from a subdirectory (verified `12 → 13` reminder from `_data/`) | FIXED |
| WR-02 | `Psych.safe_load` entry | Library probe: `!ruby/object:String` → `Psych::DisallowedClass` rejected; the same rescue branch exercised end-to-end via an unquoted timestamp (`Time` → DisallowedClass → Chinese message). Hierarchy probed: `Psych::SyntaxError` and `Psych::DisallowedClass` both `< Psych::Exception < RuntimeError < StandardError` — rescue ladder order (specific→general) is sound, no shadowing | FIXED |
| IN-01 | Unified opener regex `@\s*[a-zA-Z]\w*\s*\{` | `@article {wang2026maize,` spaced-form duplicate → `引用键 wang2026maize 重复出现 2 次` (was missed before) | FIXED (residual edge remains — see IN-01 below) |
| IN-02 | Single bib disk read | Code inspection: `raw` read once (line 153), reused by parse (155), key scan (192), D-08 work count (224) | FIXED |
| IN-03 | Dead `counts = {}` removed | Line 58 `transform_values` is the sole initialization | FIXED |

Also re-verified this round: unquoted ISO date `2026-05-01` parses as `Date` (permitted) and is correctly rejected by the structure layer as `date 格式不合法（2026-05-01）`; anchors/aliases parse with shared references; undefined alias (`Psych::AnchorNotDefined`) lands in the generic StandardError rescue with a Chinese message; D-08 reminder text matches the D-08 locked copy verbatim, fires on a legitimate 13th entry with exit 0, and writes nothing (`git status` clean apart from the probe edit — P-03-1 read-only and P-03-3 publications.md-untouched both hold); the phase diff to `deploy.yml` is exactly the 2-line `Validate content` step, correctly placed before the Jekyll build so a FAIL blocks the deploy.

### New concerns

Two new Warnings, both empirically proven: (1) the bib encoding precheck is locale-dependent — under `LANG=C`, a **valid UTF-8** `ref.bib` containing non-ASCII bytes fails with a false「含非 UTF-8 字节」verdict, blocking legal content (P-03-2) with a diagnosis (re-save as UTF-8) that fixes nothing; (2) the YAML syntax-error message cites Psych's **context mark** (where the enclosing construct started), not the mistake's position — block-mapping mistakes anywhere in a data file report「第 1 行第 1 列」. Neither was introduced by the gap-closure commits; both survived the prior round's verification because format (not accuracy / not locale) was checked.

## Warnings

### WR-01: Locale-dependent false「含非 UTF-8 字节」verdict blocks legal content (P-03-2)

**File:** `scripts/validate.rb:153-157`
**Issue:** `File.read` is called without an explicit encoding mode, so the returned string is tagged with the process's default external encoding. Under a non-UTF-8 locale (`LANG=C` / `LC_ALL=C`, typical of bare SSH sessions and minimal containers), `Encoding.default_external` is `US-ASCII`; any non-ASCII byte then makes `raw.valid_encoding?` return false — even when the file is perfectly valid UTF-8. Proven in a sandbox clone:

```text
$ printf '@article{cn2026,\n  title={基因组编辑新方法}, ... }' >> papers/ref.bib
$ file papers/ref.bib
papers/ref.bib: Unicode text, UTF-8 text
$ bundle exec ruby scripts/validate.rb        # normal locale
PASS: ..., bib=13, 键唯一                        exit=0
$ env LANG=C LC_ALL=C bundle exec ruby scripts/validate.rb
FAIL: 1 个问题
papers/ref.bib 含非 UTF-8 字节（多为编辑器以 GBK 等编码保存）——请以 UTF-8 重新保存
exit=1
```

The verdict is false and the prescribed remedy (re-save as UTF-8) changes nothing, so the maintainer is stuck — exactly the「不误伤正常提交」failure D-08/P-03-2 forbids. CI is unaffected (GitHub runners set `LANG=en_US.UTF-8`), so this is a local-maintainer trap, the same population WR-01-last-round protected. The YAML layer is immune (verified: Chinese `news.yml` under `LANG=C` still parses PASS — libyaml validates the bytes and ignores the Ruby encoding tag), so the fix is needed only on the bib read. Note the D-08 guard's `raw.valid_encoding?` re-check (line 222) shares the tag but only ever skips a reminder, so it is harmless.

**Fix:**
```ruby
raw = File.read(File.join(ROOT, BIB_PATH), mode: "r:UTF-8")
```

This makes the encoding tag locale-independent; genuinely GBK-saved files still fail `valid_encoding?` and keep the existing Chinese verdict (probe still passes under UTF-8 locale).

### WR-02: YAML syntax-error line/column point at the enclosing construct's start, not the mistake —「第 1 行第 1 列」for almost every block-mapping error

**File:** `scripts/validate.rb:48-49`
**Issue:** The message interpolates `e.line`/`e.column` as if they located the error, but psych 5.3.1's `Psych::SyntaxError` exposes the **context mark** (where the enclosing block/construct began), not the problem mark. For the data files' shape (a top-level block sequence starting at line 1 column 1), that is `1, 1` regardless of where the maintainer's mistake is. Verified end-to-end (mistake deliberately on line 3 of `news.yml`):

```text
$ printf -- '- date: "May 2026"\n  headline: ok\n bad_indent: [\n' > _data/news.yml
FAIL: 1 个问题
news.yml 第 1 行第 1 列：YAML 语法错误（did not find expected '-' indicator）
```

And in isolation: a mistake on physical line 5 of a mapping reports `e.line=1 e.column=1`; a tab violation on line 6 reports line 5 (where the enclosing plain scalar started). D-07 promises「文件名/字段名/行号保持原样」as the core maintainer UX; a line number that is wrong in the common case actively misdirects (the maintainer stares at line 1, which is always `- date: "Latest"`-shaped boilerplate). It never false-blocks or crashes, hence Warning. Not a regression from the gap-closure commits — the rendering predates them; the prior round verified the message's *format*, not its *location accuracy*.

**Fix:** Present the coordinates as the construct origin, not the error site, and include psych's context phrase so the message cannot over-claim:

```ruby
rescue Psych::SyntaxError => e
  loc = "第 #{e.line} 行第 #{e.column} 列开始的#{e.context ? e.context.sub(/\Awhile (parsing|scanning) /, '') : '结构'}内"
  errors << "#{basename}：YAML 语法错误（#{e.problem}）——#{loc}，请检查该结构附近最近的编辑"
```

(If pin-point lines are wanted, psych 5.3.1 offers no problem-mark accessor on `SyntaxError` — the context mark is all there is — so qualify the claim rather than move it.)

## Info

### IN-01: `@article { key,` (space after the brace) still evades the key-uniqueness tally while being counted as an entry

**File:** `scripts/validate.rb:192` (vs `:210`)
**Issue:** The gap-closure unified the *opener* subpattern (`@\s*[a-zA-Z]\w*\s*\{`), but the key regex still requires the key to start immediately after `{`: `\{([^,\s]+)` cannot skip whitespace. Verified in a sandbox clone:

```text
$ printf '@article { wang2026maize,\n  title={Dup}, ... }' >> papers/ref.bib
提醒：ref.bib 条目数 12 → 13 已变化；...
PASS: news=6, ..., bib=13, 键唯一   ← duplicate silently renamed by bibtex-ruby, yet 键唯一 is asserted
exit=0
```

The PASS line asserts「键唯一」on an incomplete view — the exact silent-rename trap layer ⑤ exists to prevent, now confined to the space-after-brace spelling (bibtex-ruby accepts it; the repo's uniform style is `@article{key,`, so this is latent). One-word fix: allow whitespace after the brace, and note that `[^,\s]+` then still stops at the comma.

**Fix:**
```ruby
raw.scan(/@\s*[a-zA-Z]\w*\s*\{\s*([^,\s]+)\s*,/)
```

(Re-run the IN-01 probe pair after changing — the `@article {key,` case must stay caught.)

### IN-02: Top-level workflow `permissions` grant `pages: write, id-token: write` to the build job, which needs neither

**File:** `.github/workflows/deploy.yml:13-16`
**Issue:** Job-level least privilege would scope `pages: write` + `id-token: write` to the `deploy` job only; the `build` job (checkout, validate, jekyll build, artifact upload) needs only `contents: read`. Pre-existing Phase-2 structure — this phase's diff is only the 2-line `Validate content` step, which is itself clean (static `run:` line, correct position before the build, `bundler-cache: true` guarantees the bibtex gem is installed before `bundle exec ruby scripts/validate.rb` runs). Flagged for the record, not as a phase defect.

**Fix:**
```yaml
permissions:
  contents: read
jobs:
  build:
    permissions:
      contents: read
  deploy:
    permissions:
      contents: read
      pages: write
      id-token: write
```

---

_Reviewed: 2026-08-20T07:43:19Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
