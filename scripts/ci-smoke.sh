#!/usr/bin/env bash
# scripts/ci-smoke.sh —— D-08 冒烟断言（本地: scripts/ci-smoke.sh _site；CI: 同）
set -euo pipefail
SITE="${1:-_site}"

# ① sitemap.xml 存在且含足够 URL（D-11 后应为 11：home/about/research/publications/
#    software/team/news/contact/blogs/teaching/talks；用 -ge 10 防脆断）
COUNT=$(grep -c "<loc>" "$SITE/sitemap.xml")
[ "$COUNT" -ge 10 ] || { echo "FAIL: sitemap only $COUNT URLs"; exit 1; }

# ② 出版物页含文献条目锚点（锚点建议见 RESEARCH Pattern 4；DOI 子串最稳。
#    锚点证明的是"出版物页渲染出了内容"，不是 scholar 在跑 —— scholar 失败的
#    真信号是构建红（未知 {% bibliography %} 标签），talks 空列表是已知内容态，勿断言）
grep -q "s41467-026-73769-8" "$SITE/publications/index.html" \
  || { echo "FAIL: publications anchor missing"; exit 1; }

# ③ feed.xml 为合法 XML（xmllint 在 ubuntu runner 上需先 apt 装 libxml2-utils）
xmllint --noout "$SITE/feed.xml" || { echo "FAIL: feed.xml invalid"; exit 1; }

# ④ vendor tripwire（D-10 的断言面：即便排除机制失效也拦得住发布）
[ ! -d "$SITE/vendor" ] || { echo "FAIL: vendor leaked into _site"; exit 1; }

echo "PASS: sitemap=$COUNT, anchor ok, feed valid, no vendor"
