#!/usr/bin/env bash

rake version:bump:revision

git add .
git commit -m $0
git push