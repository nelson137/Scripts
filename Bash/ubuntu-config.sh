#!/bin/bash

# root passwd
change-root-pass() {
	if [ "$#" -gt 0 ]; then
		sudo echo "
Change root password..."
	else
		sudo echo "Change root password..."
	fi
	sudo passwd root || change-root-pass "again"
}
change-root-pass



errors=()



installations() {
	# apt
	sudo apt-add-repository ppa:webupd8team/sublime-text-3 -y || errors+=("Adding the Sublime Text 3 source to sources.list")
	sudo apt-get update || errors+=("Updating the system")
	sudo apt-get upgrade -y || errors+=("Upgrading the system")
	sudo apt-get install sl vim git virtualenv libxss1 libappindicator1 libindicator7 sublime-text-installer apache2 -y || errors+=("apt-get installations")
	sudo chown -R `whoami`:`whoami` /var/www || errors+=("Giving user full permissions to /var/www")

	# git
	git clone https://github.com/nelson137/scripts.git "$HOME/Projects/Git/scripts" || errors+=("Cloning the scripts repository from Github")

	# Google Grive
	wget -O "$HOME/Pictures/orion-nebula.jpg" "https://drive.google.com/uc?id=0B3AM8GpU5FlwVlF3REMyQ1FnTTg&export=download" || errors+=("Downloading the orion-nebula.jpg wallpaper from Google Drive")
	wget -O "$HOME/Downloads/vault-key.zip" "https://drive.google.com/uc?id=0B3AM8GpU5FlwUHZiM0JIamxJc0E&export=download" &&
	unzip "$HOME/Downloads/vault-key.zip" -d "$HOME/Projects/Web/Flask/" &&
	rm "$HOME/Downloads/vault-key.zip" || errors+=("Downloading vault-key.zip from Google Drive")
	
	# Google Chrome
	wget -O "$HOME/Downloads/google-chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" &&
	sudo apt-get install -f -y &&
	sudo dpkg -i "$HOME/Downloads/google-chrome.deb" &&
	rm "$HOME/Downloads/google-chrome.deb" || errors+=("Downloading Google Chrome")

	# Tor
	wget -O "$HOME/Downloads/tor.tar.xz" "https://github.com/TheTorProject/gettorbrowser/releases/download/v6.5.1/tor-browser-linux64-6.5.1_en-US.tar.xz" &&
	mkdir "$HOME/tor" && tar -xf "$HOME/Downloads/tor.tar.xz" -C "$HOME/tor/" --strip-components=1 &&
	rm "$HOME/Downloads/tor.tar.xz" || errors+=("Downloading Tor")
}



system() {
	# System Settings
	gsettings set org.gnome.desktop.session idle-delay 1800 || errors+=("Changing the delay for turning the screen off when inactive")

	# ~/.bashrc
	bachrc_text='source ~/.bash_additions'
	bash_additions_text='################
### MY EDITS ###
################

mkcd() {
	if [ "$#" -ne "1" ]; then
		echo "E: mkcd can only take 1 argument: [dir]"
	else
		mkdir -p -- "$1" && cd -P -- "$1"
	fi
}

border-text() {
	if [ "$#" -gt "0" ]; then
		b="#"
		lines=("$@")
		widest="0"
		for l in "${lines[@]}"; do if [ "${#l}" -gt "$widest" ]; then widest="${#l}"; fi; done
		full_widest="$((widest+4))"
		echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
		for l in "${lines[@]}"; do
			width="${#l}"
			if [ "$width" != "$widest" ]; then
				echo "$b $l`printf " %.0s" $(seq 1 $((widest-width)))` $b"
			else
				echo "$b $l $b"
			fi
		done
		echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
	else
		echo "E: border-text requires an array of lines to border"
	fi
}

mygpp() {
	if [ "$@" -ne "1" ]; then
		echo "E: mygpp can only take 1 argument: [input_file]"
	else
		g++ "$1" -o "${1%.cpp}"
	fi
}

export PATH="$HOME/bin:$PATH"
alias r="source $HOME/.bashrc"
source "$HOME/.virtualenvs/MainEnv/bin/activate"'
	echo "$bash_additions_text" > "$HOME/.bash_additions"
	if [ -f "$HOME/.bashrc" ]; then
		echo "
$bashrc_text" >> "$HOME/.bashrc"
	else
		echo "$bashrc_text" > "$HOME/.bashrc"
	fi
	source "$HOME/.bash_additions"

	# ~/.vimrc
	vimrc_text="set whichwrap+=<,>,[,]"
	if [ -f "$HOME/.vimrc" ]; then
		echo "
$vimrc_text" >> "$HOME/.vimrc"
	else
		echo "$vimrc_text" > "$HOME/.vimrc"
	fi

	# Startup Apps
	mkdir "$HOME/.config/autostart/"
	term_on_startup_text='[Desktop Entry]
Name=Terminal
Type=Application
Exec=/usr/bin/gnome-terminal
X-GNOME-Autostart-enabled=true
Hidden=false'
	echo "$term_on_startup_text" > "$HOME/.config/autostart/gnome-terminal.desktop"

	# Home Hierarchy
	cd ~
	mkdir -p .virtualenvs bin Projects && cd Projects
	mkdir -p Bash Git Python Web/Flask

	# ~/bin
	cd "$HOME/Projects/Git/scripts/Bash"
	scripts=( * )
	for s in ${scripts[@]}; do
		sans_ext="${s%.sh}"
		if [ ! -f "$HOME/bin/$sans_ext" ]; then
			ln -s "$HOME/Projects/Git/scripts/Bash/$s" "$HOME/bin/$sans_ext" || errors+=("Creating ~/bin links")
		fi
	done

	# Virtualenvs
	virtualenv -p python3.5 "$HOME/.virtualenvs/MainEnv" || errors+=("Creating MainEnv")
	source "$HOME/.virtualenvs/MainEnv/bin/activate" || errors+=("Sourcing MainEnv")
	pip install myplatform flask requests || errors+=("Installing myplatform, flask, and requests to MainEnv")
}



visuals() {
	# Launcher Favorites
	gsettings set com.canonical.Unity.Launcher favorites '["unity://expo-icon","application://firefox.desktop","application://google-chrome.desktop","application://gnome-terminal.desktop","application://org.gnome.Nautilus.desktop","application://sublime-text.desktop","unity://running-apps"]' || errors+=("Setting the Launcher Favorites order")

	# Wallpaper
	gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/orion-nebula.jpg" || errors+=("Setting the wallpaper")

	# Terminal Profile
	profile="/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9"
	dconf write "$profile/visible-name" "'Main'" || errors+=("Changing the terminal profile's settings")
	#dconf write "$profile/default-size-columns" 80 || errors+=("Changing the terminal profile's settings" #default=80)
	#dconf write "$profile/default-size-rows 24" || errors+=("Changing the terminal profile's settings" #default=24)
	dconf write "$profile/use-transparent-background" true || errors+=("Changing the terminal profile's settings")
	dconf write "$profile/background-transparency-percent" 20 || errors+=("Changing the terminal profile's settings")
	dconf write "$profile/cursor-shape" "'ibeam'" || errors+=("Changing the terminal profile's settings")
}



programs() {
	# Firefox
	firefox_user_text='// UI bar widgets
	user_pref("browser.uiCustomization.state", "{\"placements\":{\"PanelUI-contents\":[\"zoom-controls\",\"new-window-button\",\"privatebrowsing-button\",\"save-page-button\",\"history-panelmenu\",\"fullscreen-button\",\"preferences-button\",\"add-ons-button\",\"developer-button\"],\"addon-bar\":[\"addonbar-closebutton\",\"status-bar\"],\"PersonalToolbar\":[\"personal-bookmarks\"],\"nav-bar\":[\"urlbar-container\",\"bookmarks-menu-button\",\"downloads-button\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"toolbar-menubar\":[\"menubar-items\"]},\"seen\":[\"loop-button\",\"pocket-button\",\"developer-button\"],\"dirtyAreaCache\":[\"PersonalToolbar\",\"nav-bar\",\"PanelUI-contents\",\"addon-bar\",\"TabsToolbar\",\"toolbar-menubar\"],\"currentVersion\":6,\"newElementCount\":0}");
	// Show my windows and tabs from last time
	user_pref("browser.startup.page", 3);
	// Clicking once in urlbar selects all
	user_pref("browser.urlbar.clickSelectsAll", true);
	// Enable search suggestions
	user_pref("browser.search.suggest.enabled", true);
	user_pref("browser.urlbar.suggest.searches", true);
	// Homepage
	user_pref("browser.startup.homepage", "about:newtab");
	// Newtab blank
	user_pref("browser.newtabpage.enabled", false);
	user_pref("browser.newtabpage.enhanced", false);
	// Do not show about:config warning
	user_pref("general.warnOnAboutConfig", false);
	// Default search engine
	/*
	user_pref("browser.search.selectedEngine", "DuckDuckGo");
	user_pref("browser.search.order.1", "DuckDuckGo");
	user_pref("browser.search.order.US.1", "data:text/plain,browser.search.order.US.1=DuckDuckGo");
	user_pref("browser.search.order.2", "Google");
	user_pref("browser.search.order.US.2", "data:text/plain,browser.search.order.US.2=Google");
	user_pref("browser.search.order.3", "Bing");
	user_pref("browser.search.order.US.3", "data:text/plain,browser.search.order.US.3=Bing");
	user_pref("browser.search.defaultenginename", "DuckDuckGo");
	user_pref("browser.search.defaultenginename.US", "data:text/plain,browser.search.defaultenginename.US=DuckDuckGo");
	*/'

	while IFS= read -r line; do
		if [[ "$line" == "Path="* ]]; then
			profile="${line:5}"
		fi
	done < "$HOME/.mozilla/firefox/profiles.ini"

	if [ -f "$HOME/.mozilla/firefox/$profile/user.js" ]; then
	    echo "
$firefox_user_text" >> "$HOME/.mozilla/firefox/$profile/user.js" || errors+=("Changing Firefox settings")
	else
	    echo "$firefox_user_text" > "$HOME/.mozilla/firefox/$profile/user.js" || errors+=("Changing Firefox settings")
	fi

	# Google Chrome
	google-chrome & export pid_chrome="$!" && sleep 3 && kill -9 "$pid_chrome" || errors+=("Starting then stopping Google Chrome")
	
	# Sublime Text
	subl & export pid_subl="$!" && sleep 2 && kill -9 "$pid_subl" || errors+=("Starting then stopping Sublime Text")

	wget -O "$HOME/.config/sublime-text-3/Installed Packages/Package Control.sublime-package" "https://packagecontrol.io/Package%20Control.sublime-package" || errors+=("Downloading the Sublime Text Package Control")

	installed_packages_text='{
		"installed_packages":
		[
			"A File Icon",
			"Bash Build System",
			"Git",
			"Package Control",
			"PackageResourceViewer",
			"Virtualenv"
		]
	}'
	echo "$installed_packages_text" > "$HOME/.config/sublime-text-3/Packages/User/Package Control.sublime-settings" || errors+=("Writing the Sublime Text Package Control file for installed_packages")
}



installations
system
visuals
programs

if [ "${#errors[@]}" -gt "0" ]; then
	border-text "${errors[@]}" > "$HOME/errors.txt"
fi

echo ""
echo "Errors:"
for e in "${errors[@]}"; do
	echo "$e"
done

#sudo reboot
