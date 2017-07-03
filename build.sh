#!/bin/sh

# remove current work dir
rm -rf ./public || exit 1

# checkout gh-pages to public dir
git worktree add public origin/gh-pages || exit 1

# build, will create new 
hugo || exit 1

last_commit_msg=$(git log --pretty=oneline | head -n1 | perl -pe 's|\w+\s+(.+)\s*$|\1|')
echo "\nPlease check the code and run something like:"
cat << EOF
cd ./public &&\\
 git add --all &&\\
 git commit -m '$last_commit_msg' &&\\
 git push origin/gh-pages &&\\
 popd
EOF
