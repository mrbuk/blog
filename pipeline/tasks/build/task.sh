#!/bin/sh

cd blog
rm -rf public/*
hugo -t slim
echo "mrbuk.de" > public/CNAME
