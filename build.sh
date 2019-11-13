#!/bin/sh

#
# do the cleanup only if git worktree not configured

git submodule init
git submodule update --remote

if [ ! -d .git/worktrees/public/ ]; then
    echo "No worktree for public found. Cleaning up and creatin" 

    rm -rf public
    mkdir public
    git worktree prune
    rm -rf .git/worktrees/public/

    git worktree add -B gh-pages public origin/gh-pages || exit 1
fi


# delete old files. this will keep the .git dir
rm -rf public/*
echo "blog.mrbuk.de" > public/CNAME

# build, will create new 
hugo -t slim || exit 1

# determine last commit
last_commit_msg=$(git log --pretty=oneline | head -n1 | perl -pe 's|\w+\s+(.+)\s*$|\1|')
echo "\nPlease check the code and run something like:"
cat << EOF
 cd ./public
 git add --all
 git commit -m "$last_commit_msg"
 git push
 popd
EOF
