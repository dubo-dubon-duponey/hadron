#!/usr/bin/env bash

foo(){
        local input="${1:-/dev/stdin}"
        cat "$input"
}


foo <<<"blah"


