#!/bin/bash

errors=("Errors:")

pre-setup() {
	# root passwd
	root-pass() {
		if [[ $# > 0 ]]; then
			sudo echo ""
		fi
		sudo echo "Change root password..."
		sudo passwd root || root-pass "again"
	}
	root-pass
	
	# Home Hierarchy
	echo ""; echo "Setting up home hierarchy..."
	cd "$HOME"
	rm examples.desktop
	mkdir -p .virtualenvs bin Projects && cd Projects && mkdir -p Bash Git Python Web/Flask
}

installations() {
	# apt
	echo ""; echo "Aptitude installations..."
	sudo apt-add-repository ppa:webupd8team/sublime-text-3 -y || errors+=("installations: adding the sublime text repository")
	sudo apt-add-repository ppa:neurobin/ppa -y || errors+=("installations: adding the Shc repository")
	sudo apt-get update || errors+=("installations: apt-get update")
	#sudo apt-get upgrade -y || errors+=("installations: apt-get upgrade")
	sudo apt-get install vim git virtualenv sublime-text-installer xdotool tmux python3-tk apache2 shc -y || errors+=("installations: apt-get")
	sudo chown -R `whoami`:`whoami` /var/www/ || errors+=("installations: giving user full permissions to /var/www/")

	# git
	echo ""; echo "Cloning Git tools and repositories..."
	git clone "https://github.com/nelson137/scripts.git" "$HOME/Projects/Git/scripts/" || errors+=("git: cloning scripts repository")
	git clone "https://github.com/nelson137/wallpapers.git" "$HOME/Projects/Git/wallpapers/" || errors+=("git: cloning wallpapers repository")
	rm -r "$HOME/Pictures/"
	ln -s "$HOME/Projects/Git/wallpapers/Pictures/" "$HOME/"
	sudo wget -O /usr/local/bin/git-cache-meta "https://gist.githubusercontent.com/andris9/1978266/raw/9645c54ccc3c4af70bffb6fecdd396c25ea689d9/git-cache-meta.sh" || errors+=("git-cache-meta: downloading")
	sudo chmod +x /usr/local/bin/git-cache-meta || errors+=("git-cache-meta: making executable")

	# Google Chrome
	echo ""; echo "Installing Google Chrome..."
	wget -O "$HOME/Downloads/google-chrome.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" || errors+=("Google Chrome: downloading")
	sudo dpkg -i "$HOME/Downloads/google-chrome.deb" || sudo apt-get install -f -y && sudo dpkg -i "$HOME/Downloads/google-chrome.deb" || errors+=("Google Chrome: unpacking")
	rm "$HOME/Downloads/google-chrome.deb" || errors+=("Google Chrome: deleting deb")

	# Tor
	echo ""; echo "Installing Tor..."
	wget -O "$HOME/Downloads/tor.tar.xz" "https://github.com/TheTorProject/gettorbrowser/releases/download/v6.5.1/tor-browser-linux64-6.5.1_en-US.tar.xz" || errors+=("Tor: downloading")
	mkdir "$HOME/tor" && tar -xf "$HOME/Downloads/tor.tar.xz" -C "$HOME/tor/" --strip-components=1 || errors+=("Tor: unpacking")
	rm "$HOME/Downloads/tor.tar.xz" || errors+=("Tor: deleting tar.xz")
}



system() {
	# System Settings
	echo ""; echo "Updating system settings..."
	gsettings set org.gnome.desktop.session idle-delay 1800 || errors+=("system settings: changing the delay for turning the screen off when inactive")
	
	# Virtualenvs
	echo ""; echo "Setting up virtualenvs..."
	virtualenv -p python3.5 "$HOME/.virtualenvs/MainEnv" --system-site-packages || errors+=("MainEnv: creation")
	source "$HOME/.virtualenvs/MainEnv/bin/activate" || errors+=("MainEnv: activating")
	pip install myplatform flask requests || errors+=("MainEnv: installing myplatform, flask, and requests")
	
	# .bashrc
	echo ""; echo "Updating .bashrc..."
	bashrc_text='source ~/.bash_additions'
	ln -s "$HOME/Projects/Git/scripts/Bash/DotFiles/.bash_additions" "$HOME/" || errors+=("bashrc: creating .bash_additions symbolic link")
	if [[ -f $HOME/.bashrc ]]; then
		echo "
$bashrc_text" >> "$HOME/.bashrc"
	else
		echo "$bashrc_text" > "$HOME/.bashrc"
	fi

	# .vimrc
	echo ""; echo "Updating .vimrc..."
	vimrc_text="set whichwrap+=<,>,[,]"
	if [[ -f $HOME/.vimrc ]]; then
		echo "
$vimrc_text" >> "$HOME/.vimrc"
	else
		echo "$vimrc_text" > "$HOME/.vimrc"
	fi

	# Startup Apps
	echo ""; echo "Creating startup app entries..."
	mkdir "$HOME/.config/autostart/"
	term_on_startup_text='[Desktop Entry]
Name=Terminal
Type=Application
Exec=/usr/bin/gnome-terminal
X-GNOME-Autostart-enabled=true
Hidden=false'
	echo "$term_on_startup_text" > "$HOME/.config/autostart/gnome-terminal.desktop"

	# ~/bin
	echo ""; echo "Creating ~/bin symbolic links..."
	files=($HOME/Projects/Git/scripts/Bash/*)
	for f in "${files[@]}"; do
		if [[ -f $f ]]; then
			bin_path="$HOME/bin/$(echo ${f%.sh} | cut -d '/' -f 8)"
			if [[ ! -f $bin_path ]]; then
				ln -s "$f" "$bin_path"
			fi
		fi
	done
}



visuals() {
	# Launcher Favorites
	echo ""; echo "Updating launcher favorites..."
	gsettings set com.canonical.Unity.Launcher favorites '["unity://expo-icon","application://firefox.desktop","application://google-chrome.desktop","application://gnome-terminal.desktop","application://org.gnome.Nautilus.desktop","application://sublime-text.desktop","unity://running-apps"]' || errors+=("setting the launcher favorites order")

	# Wallpaper
	echo ""; echo "Updating wallpaper..."
	gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/orion-nebula.jpg" || errors+=("setting the wallpaper")

	# Terminal Profile
	echo ""; echo "Updating Terminal profile..."
	term_profile="/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9"
	dconf write "$term_profile/visible-name" "'Main'" || errors+=("terminal profile: setting the name")
	#dconf write "$term_profile/default-size-columns" 80 || errors+=("terminal profile: setting the default columns") #default=80
	#dconf write "$term_profile/default-size-rows 24" || errors+=("terminal profile: setting the default rows") #default=24
	dconf write "$term_profile/use-transparent-background" true || errors+=("terminal profile: setting transparent bg")
	dconf write "$term_profile/background-transparency-percent" 20 || errors+=("terminal profile: setting transparent bg %")
	dconf write "$term_profile/cursor-shape" "'ibeam'" || errors+=("terminal profile: setting the cursor shape")
}



programs() {
	# Git
	echo ""; echo "Configuring Git..."
	git config --global user.name "Nelson Earle" || errors+=("git: setting name")
	git config --global user.email "nelson.earle137@gmail.com" || errors+=("git: setting email")
	git config --global push.default simple || errors+=("git: setting the default push")
	
	# Firefox
	echo ""; echo "Configuring Firefox..."
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
	firefox &
	for ((i=0; i<10; i++)); do
		sleep 1
		window=$(xdotool search --all --onlyvisible --pid "$(pgrep firefox)")
		if [[ ${#window} > 0 ]]; then
			#xdotool windowfocus "$window" key "Control_L+q"
			kill -9 "$(pgrep firefox)"
			break
		elif [[ $i == 9 ]]; then
			errors+=("Firefox: closing window")
		fi
	done
	while IFS= read -r line; do
		if [[ $line == Path=* ]]; then
			ff_profile="${line:5}"
		fi
	done < "$HOME/.mozilla/firefox/profiles.ini"

	if [[ -f $HOME/.mozilla/firefox/$ff_profile/user.js ]]; then
	    echo "
$ff_user_text" >> "$HOME/.mozilla/firefox/$ff_profile/user.js" || errors+=("Firefox: settings")
	else
	    echo "$ff_user_text" > "$HOME/.mozilla/firefox/$ff_profile/user.js" || errors+=("Firefox: settings")
	fi

	# Google Chrome
	echo ""; echo "Configuring Google Chrome..."
	google-chrome &
	for ((i=0; i<10; i++)); do
		sleep 1
		window=$(xdotool search --all --onlyvisible --pid "$(pgrep chrome)" --name "")
		if [[ ${#window} > 0 ]]; then
			#xdotool mousemove --sync --window "$window" 440 105 click 1
			kill -9 "$(pgrep chrome)"
			break
		elif [[ $i == 9 ]]; then
			errors+=("Google Chrome: closing first-time-open menu")
		fi
	done

	for ((i=0; i<10; i++)); do
		sleep 1
		window=$(xdotool search --all --onlyvisible --pid "$(pgrep chrome)")
		if [[ ${#window} > 0 ]]; then
			xdotool windowfocus "$window" key "Control_L+q"
			break
		elif [[ $i == 9 ]]; then
			errors+=("Google Chrome: closing window")
		fi
	done
	
	# Sublime Text
	echo ""; echo "Configuring Sublime Text..."
	subl
	for ((i=0; i<10; i++)); do
		window=$(xdotool search --all --onlyvisible --pid "$(pgrep sublime_text)")
		if [[ ${#window} > 0 ]]; then
			#xdotool windowfocus "$window" key "Control_L+q"
			kill -9 "$(pgrep sublime_text)"
			break
		elif [[ $i == 9 ]]; then
			errors+=("Sublime Text: closing window")
		fi
	done
	wget -O "$HOME/.config/sublime-text-3/Installed Packages/Package Control.sublime-package" "https://packagecontrol.io/Package%20Control.sublime-package" || errors+=("Sublime Text: downloading Package Control")
	installed_packages='{
	"installed_packages":
	[
		"A File Icon",
		"Bash Build System",
		"Emmet",
		"Git",
		"Package Control",
		"PackageResourceViewer",
		"Virtualenv"
	]
}
'
	subl_prefs='{
	"ignored_packages":
	[
		"Vintage"
	],
	"rulers":
	[
		80
	],
	"open_files_in_new_window": false,
	"close_windows_when_empty": false,
	"ensure_newline_at_eof_on_save": true,
	"detect_indentation": false,
	"translate_tabs_to_spaces": false,
	"match_brackets_angle": true,
	"drag_text": true,
}
'
	echo "$installed_packages" > "$HOME/.config/sublime-text-3/Packages/User/Package Control.sublime-settings" || errors+=("Sublime Text: Package Control installed_packages")
	echo "$subl_prefs" > "$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings" || errors+=("Sublime Text: Preferences")
}



pre-setup
installations
system
visuals
programs

if [[ ${#errors[@]} > 1 ]]; then
	for e in "${errors[@]}"; do
		echo "$e" >> "$HOME/config-errors.log"
	done
fi

#sudo reboot
