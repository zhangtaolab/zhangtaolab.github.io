#!/usr/bin/env bash
# scripts/validate.sh —— 内容验证入口（本地维护者命令；CI 走 deploy.yml 直接调 validate.rb）
exec bundle exec ruby "$(dirname "$0")/validate.rb" "$@"
