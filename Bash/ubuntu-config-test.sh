#!/bin/bash

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



errors=("Errors:")



installations() {
	# apt
	echo ""; echo "Aptitude installations..."
	sudo apt-add-repository ppa:webupd8team/sublime-text-3 -y || errors+=("installations: adding the sublime text repository")
	sudo apt-add-repository ppa:neurobin/ppa -y || errors+=("installations: adding the Shc repository")
	sudo apt-get update || errors+=("installations: apt-get update")
	#sudo apt-get upgrade -y || errors+=("installations: apt-get upgrade")
	sudo apt-get install vim tmux git virtualenv python3-tk sublime-text-installer shc apache2 -y || errors+=("installations: apt-get")
	sudo chown -R `whoami`:`whoami` /var/www/ || errors+=("installations: giving user full permissions to /var/www/")

	# git
	echo ""; echo "Cloning Git tools and repositories..."
	git clone "https://github.com/nelson137/scripts.git" "$HOME/Projects/Git/scripts/" || errors+=("git: cloning scripts repository")
	git clone "https://github.com/nelson137/wallpapers.git" "$HOME/Projects/Git/wallpapers/" || errors+=("git: cloning wallpapers repository")
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

	# .bashrc
	echo ""; echo "Updating .bashrc..."
	bachrc_text='source ~/.bash_additions'
	ln -s "$HOME/Projects/Git/scripts/Bash/DotFiles/.bash_additions" "$HOME/" || errors+=("bashrc: creating .bash_additions symbolic link")
	if [ -f "$HOME/.bashrc" ]; then
		echo "
$bashrc_text" >> "$HOME/.bashrc"
	else
		echo "$bashrc_text" > "$HOME/.bashrc"
	fi
	source "$HOME/.bash_additions"

	# .vimrc
	echo ""; echo "Updating .vimrc..."
	vimrc_text="set whichwrap+=<,>,[,]"
	if [ -f "$HOME/.vimrc" ]; then
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
	cd "$HOME/Projects/Git/scripts/Bash/"
	files=(*)
	for f in ${files[@]}; do
		sans_ext="${s%.sh}"
		if [ ! -f "$HOME/bin/$sans_ext" ]; then
			ln -s "$HOME/Projects/Git/scripts/Bash/$f" "$HOME/bin/$sans_ext" || errors+=("~/bin: creating symbolic links")
		fi
	done

	# Virtualenvs
	echo ""; echo "Setting up virtualenvs..."
	virtualenv -p python3.5 "$HOME/.virtualenvs/MainEnv" --system-site-packages || errors+=("MainEnv: creation")
	source "$HOME/.virtualenvs/MainEnv/bin/activate" || errors+=("MainEnv: activating")
	pip install myplatform flask requests || errors+=("MainEnv: installing myplatform, flask, and requests")
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
	firefox && sleep 3 && kill -9 "$(pgrep firefox)" || errors+=("Firefox: starting then stopping")
	while IFS= read -r line; do
		if [[ $line == Path=* ]]; then
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
	echo ""; echo "Configuring Google Chrome..."
	google-chrome && sleep 3 && kill -9 "$(pgrep google-chrome)" || errors+=("Google Chrome: starting then stopping")
	
	# Sublime Text
	echo ""; echo "Configuring Sublime Text..."
	subl && sleep 2 && kill -9 "$(pgrep subl)" || errors+=("Sublime Text: starting then stopping")
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
#programs

if [[ ${#errors[@]} > 1 ]]; then
	border "${errors[@]}" > "$HOME/setup-errors.log"
fi

#sudo reboot

