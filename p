#!/bin/bash

base="$HOME/projects"
cd "$(find "$base" -mindepth 1 -maxdepth 1 -type d -print | sort \
      | fzf --height=60% --reverse --cycle --prompt="cd $base > ")" && exec bash
