#!/bin/bash

repos=(github gitlab)

for r in ${repos[@]}; do
	git push --all "$r"
done

