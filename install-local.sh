#!/usr/bin/env bash

toml_file="./typst.toml"
local_dir="$HOME/.local/share/typst/packages/local"
version=$(grep -E 'version\s*=\s*"[0-9]+\.[0-9]+\.[0-9]+"' "$toml_file" | \
  sed -E 's/version\s*=\s*"([0-9]+\.[0-9]+\.[0-9]+)"/\1/')
name=$(grep -E 'name\s*=\s*".*"' "$toml_file" | \
  sed -E 's/name\s*=\s*"(.*)"/\1/')

pack_dir="$local_dir/$name/$version"
mkdir -p $pack_dir
cp $toml_file $pack_dir
cp ./README.md $pack_dir
mkdir -p $pack_dir/src/
cp -r ./src/* $pack_dir/src/
