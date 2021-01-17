#!/usr/bin/env sh
# 确保脚本抛出遇到的错误
set -e

echo '仓库地址：'$1

# 如果是发布到自定义域名
# echo 'docs.shanyuhai.top' > CNAME

git init
git add -A
git commit -m 'master'

# 如果发布到 https://<USERNAME>.github.io
# git push -f git@github.college:<USERNAME>/<USERNAME>.github.io.git master

# 如果发布到 https://<USERNAME>.github.io/<REPO>
# 将构建发布到gh-pages上，若gh-pages不存在则新建
git push -f $1 master:gh-pages

cd -
