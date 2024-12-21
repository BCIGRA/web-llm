#!/bin/bash
set -euxo pipefail

# Setup environment
export PYTHONPATH=$PWD/python

# Build HTML dan Jekyll
cd docs && make html && cd ..
cd site && jekyll b && cd ..
rm -rf site/_site/docs
cp -r docs/_build/html site/_site/docs

# Periksa keberadaan branch gh-pages
git fetch
if git rev-parse --verify origin/gh-pages >/dev/null 2>&1; then
    git checkout -B gh-pages origin/gh-pages
else
    git checkout --orphan gh-pages
    git reset --hard
    git commit --allow-empty -m "Initialize gh-pages branch"
    git push origin gh-pages
    git checkout gh-pages
fi

# Update konten untuk deploy
rm -rf docs .gitignore
mkdir -p docs
cp -rf site/_site/* docs
touch docs/.nojekyll
echo "webllm.mlc.ai" >> docs/CNAME

# Commit dan push ke branch gh-pages
DATE=$(date)
git add docs && git commit -am "Build at ${DATE}"
git push origin gh-pages

# Kembali ke branch main
git checkout main && git submodule update
echo "Finish deployment at ${DATE}"
