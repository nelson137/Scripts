#!/bin/bash

pre-setup() {
	# root passwd
	root-pass() {
		if [ "$#" -gt 0 ]; then
			sudo echo "
	Change root password..."
		else
			sudo echo "Change root password..."
		fi
		sudo passwd root || root-pass "again"
	}
	root-pass
	
	# Home Hierarchy
	echo ""
	echo ""
	cd ~
	mkdir -p .virtualenvs bin Projects && cd Projects
	mkdir -p Bash Git Python Web/Flask
}



errors=("Errors:")



installations() {
	# apt
	echo ""
	echo "Aptitude installations..."
	sudo apt-add-repository ppa:webupd8team/sublime-text-3 -y || errors+=("adding the Sublime Text 3 source to sources.list")
	sudo apt-get update || errors+=("updating system")
	sudo apt-get upgrade -y || errors+=("upgrading system")
	sudo apt-get install sl vim git virtualenv libxss1 libappindicator1 libindicator7 sublime-text-installer apache2 -y || errors+=("apt-get installations")
	sudo chown -R `whoami`:`whoami` /var/www/ || errors+=("giving user full permissions to /var/www")

	# git
	echo ""
	echo "Cloning Git tools and repositories..."
	git clone "https://github.com/nelson137/scripts.git" "$HOME/Projects/Git/scripts/" || errors+=("cloning scripts repository from Github")
	wget -O "$HOME/bin/git-cache-meta" "https://gist.githubusercontent.com/andris9/1978266/raw/9645c54ccc3c4af70bffb6fecdd396c25ea689d9/git-cache-meta.sh" || errors+=("downloading git-cache-meta")
	chmod +x "$HOME/bin/git-cache-meta" || errors+=("making git-cache-meta executable")

	# Google Grive
	echo ""
	echo "Downloading from Google Drive..."
	wget -O "$HOME/Pictures/orion-nebula.jpg" "https://drive.google.com/uc?id=0B3AM8GpU5FlwVlF3REMyQ1FnTTg&export=download" || errors+=("downloading orion-nebula.jpg wallpaper from Google Drive")
	
	# Google Chrome
	echo ""
	echo "Installing Google Chrome..."
	wget -O "$HOME/Downloads/google-chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" || errors+=("Google Chrome: downloading")
	sudo dpkg -i "$HOME/Downloads/google-chrome.deb" || sudo apt-get install -f -y && sudo dpkg -i "$HOME/Downloads/google-chrome.deb" || errors+=("Google Chrome: unpacking")
	rm "$HOME/Downloads/google-chrome.deb" || errors+=("Google Chrome: deleting deb")

	# Tor
	echo ""
	echo "Installing Tor..."
	wget -O "$HOME/Downloads/tor.tar.xz" "https://github.com/TheTorProject/gettorbrowser/releases/download/v6.5.1/tor-browser-linux64-6.5.1_en-US.tar.xz" || errors+=("Tor: downloading")
	mkdir "$HOME/tor" && tar -xf "$HOME/Downloads/tor.tar.xz" -C "$HOME/tor/" --strip-components=1 || errors+=("Tor: unpacking")
	rm "$HOME/Downloads/tor.tar.xz" || errors+=("Tor: deleting tar.xz")
}



system() {
	# System Settings
	echo ""
	echo "Updating system settings..."
	gsettings set org.gnome.desktop.session idle-delay 1800 || errors+=("system settings: changing turn the screen off when inactive delay")

	# ~/.bashrc
	echo ""
	echo "Updating .bashrc..."
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
	echo ""
	echo "Updating .vimrc..."
	vimrc_text="set whichwrap+=<,>,[,]"
	if [ -f "$HOME/.vimrc" ]; then
		echo "
$vimrc_text" >> "$HOME/.vimrc"
	else
		echo "$vimrc_text" > "$HOME/.vimrc"
	fi

	# Startup Apps
	echo ""
	echo "Creating startup app entries..."
	mkdir "$HOME/.config/autostart/"
	term_on_startup_text='[Desktop Entry]
Name=Terminal
Type=Application
Exec=/usr/bin/gnome-terminal
X-GNOME-Autostart-enabled=true
Hidden=false'
	echo "$term_on_startup_text" > "$HOME/.config/autostart/gnome-terminal.desktop"

	# ~/bin
	echo ""
	echo "Creating ~/bin symbolic links..."
	cd "$HOME/Projects/Git/scripts/Bash/"
	scripts=( * )
	for s in ${scripts[@]}; do
		sans_ext="${s%.sh}"
		if [ ! -f "$HOME/bin/$sans_ext" ]; then
			ln -s "$HOME/Projects/Git/scripts/Bash/$s" "$HOME/bin/$sans_ext" || errors+=("creating ~/bin links")
		fi
	done

	# Virtualenvs
	echo ""
	echo "Setting up virtualenvs..."
	virtualenv -p python3.5 "$HOME/.virtualenvs/MainEnv" || errors+=("MainEnv: create")
	source "$HOME/.virtualenvs/MainEnv/bin/activate" || errors+=("MainEnv: source")
	pip install myplatform flask requests || errors+=("MainEnv: installing myplatform, flask, and requests")
}



visuals() {
	# Launcher Favorites
	echo ""
	echo "Updating launcher favorites..."
	gsettings set com.canonical.Unity.Launcher favorites '["unity://expo-icon","application://firefox.desktop","application://google-chrome.desktop","application://gnome-terminal.desktop","application://org.gnome.Nautilus.desktop","application://sublime-text.desktop","unity://running-apps"]' || errors+=("Setting the Launcher Favorites order")

	# Wallpaper
	echo ""
	echo "Updating wallpaper..."
	gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/orion-nebula.jpg" || errors+=("setting wallpaper")

	# Terminal Profile
	echo ""
	echo "Updating Terminal profile..."
	term_profile="/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9"
	dconf write "$term_profile/visible-name" "'Main'" || errors+=("terminal profile settings: name")
	#dconf write "$term_profile/default-size-columns" 80 || errors+=("terminal profile settings: columns") #default=80
	#dconf write "$term_profile/default-size-rows 24" || errors+=("terminal profile settings: rows") #default=24
	dconf write "$term_profile/use-transparent-background" true || errors+=("terminal profile settings: transparent bg")
	dconf write "$term_profile/background-transparency-percent" 20 || errors+=("terminal profile settings: transparent bg %")
	dconf write "$term_profile/cursor-shape" "'ibeam'" || errors+=("terminal profile settings: cursor shape")
}



programs() {
	# Git
	git config --global push.default simple
	
	# Firefox
	echo ""
	echo "Configuring Firefox..."
	ff_user_text='// UI bar widgets
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
	firefox && sleep 3 && kill -9 "$(pgrep firefox)" || errors+=("Firefox: starting then stopping")
	while IFS= read -r line; do
		if [[ "$line" == "Path="* ]]; then
			ff_profile="${line:5}"
		fi
	done < "$HOME/.mozilla/firefox/profiles.ini"

	if [ -f "$HOME/.mozilla/firefox/$ff_profile/user.js" ]; then
	    echo "
$ff_user_text" >> "$HOME/.mozilla/firefox/$ff_profile/user.js" || errors+=("Firefox: settings")
	else
	    echo "$ff_user_text" > "$HOME/.mozilla/firefox/$ff_profile/user.js" || errors+=("Firefox: settings")
	fi

	# Google Chrome
	echo ""
	echo "Configuring Google Chrome..."
	google-chrome && sleep 3 && kill -9 "$(pgrep google-chrome)" || errors+=("Google Chrome: starting then stopping")
	
	# Sublime Text
	echo ""
	echo "Configuring Sublime Text..."
	subl && sleep 2 && kill -9 "$(pgrep subl)" || errors+=("Sublime Text: starting then stopping")
	wget -O "$HOME/.config/sublime-text-3/Installed Packages/Package Control.sublime-package" "https://packagecontrol.io/Package%20Control.sublime-package" || errors+=("Sublime Text: downloading Package Control")
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
	echo "$installed_packages_text" > "$HOME/.config/sublime-text-3/Packages/User/Package Control.sublime-settings" || errors+=("Sublime Text: Package Control installed_packages file")
}



pre-setup
installations
system
visuals
programs

if [ "${#errors[@]}" -gt "1" ]; then
	border-text "${errors[@]}" > "$HOME/errors.txt"
fi

#sudo reboot
