#!/bin/bash

if [ "$#" -lt 2 ]; then
	echo "E: "
else
	bh="$1"
	lines="$2"
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
fi

lines=( 123 1 123467123456789865433467 12 123456789 1234567 12345 )
border-text "#" "${lines[@]}"
