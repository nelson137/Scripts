#!/bin/bash

b="#"
lines=( "$@" )
widest="0"
for l in "${lines[@]}"; do if [ "${#l}" -gt "$widest" ]; then widest="${#l}"; fi; done
full_widest="$((widest+4))"

echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
for l in "${lines[@]}"; do
	width="${#l}"
	if [ "$width" != "$widest" ]; then
		echo "$b $l`printf ' %.0s' $(seq 1 $((widest-width)))` $b"
	else
		echo "$b $l $b"
	fi
done
echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
