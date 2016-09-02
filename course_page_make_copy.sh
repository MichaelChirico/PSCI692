#!/bin/bash

pandoc -s -o course_page.html course_page.md

cp course_page.html /home/michael/Documents/githubio/MichaelChirico.github.io/upenn/psci692

if [ $# -gt 0 ]
then 
	cp "$@" /home/michael/Documents/githubio/MichaelChirico.github.io/upenn/psci692
fi
