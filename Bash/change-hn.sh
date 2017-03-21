#!/bin/bash

update-hn() {
    old="`hostname | td -d '[:space:]'`"
    read -p "New hostname: " new
    if [ "$new" == "$old" ]; then
        echo "E: That is the current hostname. Please enter something different."
        update-hn
    else
        echo "$new" > /etc/hostname
        sed -i 's/"$old"/"$new"/g' /etc/hosts
    fi
}

ask-change-hn() {
    read -p "Do you want to change this computer's hostname? [Y/n] " ans
    case "$ans" in
        Y|y) update-hn;;
        N|n) echo "Not changing hostname.";;
        *) echo "E: Invalid answer."; ask_change_hn;;
    esac
}

ask-change-hn