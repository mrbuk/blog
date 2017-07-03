#!/bin/sh

# cleanup
rm -rf public || exit 1
mkdir public
git worktree prune || exit 1
rm -rf .git/worktrees/public/

# checkout gh-pages to public dir
git worktree add -b gh-pages public origin/gh-pages || exit 1

rm -rf public/*

# build, will create new 
hugo -t slim || exit 1

last_commit_msg=$(git log --pretty=oneline | head -n1 | perl -pe 's|\w+\s+(.+)\s*$|\1|')
echo "\nPlease check the code and run something like:"
cat << EOF
cd ./public &&
 git add --all &&
 git commit -m '$last_commit_msg' &&
 git push &&
 popd
EOF
