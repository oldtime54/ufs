#!/bin/bash

# This script provides common customization options for the ISO
# 
# Usage: Copy this file to config.sh and make changes there.  Keep this file (default_config.sh) as-is
#   so that subsequent changes can be easily merged from upstream.  Keep all customiations in config.sh

# The version of Ubuntu to generate.  Successfully tested: bionic, cosmic, disco, eoan, focal, groovy, jammy
# See https://wiki.ubuntu.com/DevelopmentCodeNames for details
export TARGET_UBUNTU_VERSION="noble"

# The Ubuntu Mirror URL. It's better to change for faster download.
# More mirrors see: https://launchpad.net/ubuntu/+archivemirrors
export TARGET_UBUNTU_MIRROR="http://us.archive.ubuntu.com/ubuntu/"

# The packaged version of the Linux kernel to install on target image.
# See https://wiki.ubuntu.com/Kernel/LTSEnablementStack for details
export TARGET_KERNEL_PACKAGE="linux-generic-hwe-24.04"

# The file (no extension) of the ISO containing the generated disk image,
# the volume id, and the hostname of the live environment are set from this name.
export TARGET_NAME="ufs"

# The text label shown in GRUB for booting into the live environment
export GRUB_LIVEBOOT_LABEL="Try UFS without installing"

# The text label shown in GRUB for starting installation
export GRUB_INSTALL_LABEL="Install UFS"

# Packages to be removed from the target system after installation completes succesfully
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"

# Package customisation function.  Update this function to customize packages
# present on the installed system.
function customize_image() {
    # install graphics and desktop
    apt-get install -y \
    plymouth-theme-ubuntu-text \
    plymouth-theme-spinner \
    ubuntu-minimal \
    ubuntu-desktop-minimal \
    ubuntu-wallpapers
    
	# add i386 support
    dpkg --add-architecture i386
    
    # flatpak install
    apt-get install -y \
    flatpak
    
	# flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

	apt-get update
    
    # gnome software and flatpak    
    apt-get install --no-install-recommends -y \
    gnome-software-plugin-flatpak
        
    # remove snapd
    apt-get remove -y snapd
    
    # add firefox deb
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla

	apt-get update
	
	apt-get install -y \
	firefox
	  
    # useful tools
    apt-get install -y \
    chntpw \
    testdisk \
    clonezilla \
    curl \
    exfatprogs \
    build-essential \
    iputils-ping \
    linssid \
    git \
    dconf-editor \
    gnome-tweaks \
    libfuse2 \
    gnome-sushi \
    dbus-x11 \
    init \
    open-vm-tools \
    mesa-utils \
    synaptic \
    vim \
    nano \
    tree \
    file-roller \
    gnome-system-tools \
    efibootmgr \
    exfat-fuse \
    xfsprogs \
    less
    
    # no-recommends installs
    apt-get install --no-install-recommends -y \
    nautilus-admin
    
    # install gparted
    apt-get install -y \
    gparted \
    dmraid \
    gpart \
    jfsutils \
    kpartx \
    reiser4progs \
    udftools
    
    # add some ppa's
    add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    
    add-apt-repository -y ppa:deadsnakes/ppa
    
    apt-get update
    
    apt-get install -y \
    fastfetch
    
    # customize desktop
    cat <<EOF > /usr/share/glib-2.0/schemas/90_ubuntu-dock.gschema.override
[org.gnome.shell.extensions.dash-to-dock:ubuntu]
disable-overview-on-startup=true
show-mounts-only-mounted=true
show-mounts-network=true
dock-position='LEFT'
dock-fixed=false
intellihide-mode='ALL_WINDOWS'
intellihide=true
icon-size-fixed=true
pressure-threshold=50.0
custom-theme-shrink=true
running-indicator-style='DASHES'
extend-height=false
scroll-action='switch-workspace'
click-action='minimize-or-overview'
shift-click-action='launch'
middle-click-action='launch'
shift-middle-click-action='minimize'
show-apps-at-top=true
dash-max-icon-size=36
EOF

	cat <<EOF > /usr/share/glib-2.0/schemas/90_ubuntu-settings.gschema.override
###################
# global settings #
###################

[org.gnome.evolution-data-server.calendar]
notify-with-tray=false

[org.gnome.shell]
# This is overriden for the Ubuntu session later
favorite-apps = [ 'ubuntu-desktop-installer_ubuntu-desktop-installer.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Settings.desktop' ]

[org.gnome.desktop.interface]
monospace-font-name="Ubuntu Sans Mono 13"

[org.gnome.desktop.calendar]
show-weekdate = true

[org.gnome.desktop.interface]
clock-format = '12h'
clock-show-weekday = true
color-scheme = 'prefer-dark'
cursor-size = 32

[org.gnome.software]
show-ratings = true

[org.gnome.gedit.preferences.editor]
scheme = 'Yaru-dark'

[org.gnome.TextEditor]
highlight-current-line = true
restore-session = false
show-line-numbers = true
style-scheme = 'Yaru-dark'
tab-width = 4

[org.gnome.desktop.sound]
allow-volume-above-100-percent = true
theme-name = 'Yaru'
input-feedback-sounds = true

[org.gnome.desktop.session]
session-name = "ubuntu"

[org.gnome.eog.ui]
sidebar = false

[org.gnome.Epiphany]
default-search-engine = 'Google'
search-engines = [('DuckDuckGo', 'https://duckduckgo.com/?q=%s&amp;t=canonical', '!ddg'), ('Google', 'https://www.google.com/search?client=ubuntu&channel=es&q=%s', '!g'), ('Bing', 'https://www.bing.com/search?q=%s', '!b')]

[org.gnome.crypto.pgp]
keyservers = ['hkp://keyserver.ubuntu.com:11371', 'ldap://keyserver.pgp.com']

[org.onboard]
layout = 'Compact'
theme = 'Nightshade'
key-label-font = 'Ubuntu Sans'
key-label-overrides = ['RWIN::super-group', 'LWIN::super-group']
xembed-onboard = true

[org.onboard.window]
docking-enabled = true
force-to-top = true

[org.gnome.rhythmbox.rhythmdb]
monitor-library=true

[org.gnome.rhythmbox.plugins]
active-plugins=['artsearch', 'audiocd','audioscrobbler','cd-recorder','daap','dbus-media-server','generic-player','ipod','iradio','mmkeys','mpris','mtpdevice','notification','power-manager']

[org.gnome.rhythmbox.encoding-settings]
media-type-presets = {'audio/x-vorbis':'Ubuntu', 'audio/mpeg':'Ubuntu'}

[org.gnome.settings-daemon.plugins.power]
power-button-action = 'interactive'
sleep-inactive-ac-timeout = 0

[org.gnome.software]
first-run=false

# for GDM/DM
# FIXME: move to :Ubuntu-Greeter once upstream supports this, see LP: #1788010
[org.gnome.desktop.interface:GNOME-Greeter]
gtk-theme = "Yaru"
icon-theme = "Yaru"
cursor-theme = "Yaru"
font-name = "Ubuntu Sans 11"
monospace-font-name = "Ubuntu Sans Mono 13"
font-antialiasing = 'rgba'

[org.gnome.login-screen]
logo='/usr/share/plymouth/ubuntu-logo.png'

##################################
# ubuntu common session settings #
##################################

[org.gnome.shell:ubuntu]
always-show-log-out = true
favorite-apps = [ 'ubuntu-desktop-installer_ubuntu-desktop-installer.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Settings.desktop' ]

[org.gnome.shell.extensions.ding:ubuntu]
show-home = false
show-trash = false
show-volumes = false
start-corner = 'bottom-right'
arrangeorder = 'DESCENDINGNAME'

[org.gnome.desktop.background:ubuntu]
picture-uri = 'file:///usr/share/backgrounds/warty-final-ubuntu.png'
picture-uri-dark = 'file:///usr/share/backgrounds/ubuntu-wallpaper-d.png'
show-desktop-icons = true

[org.gnome.desktop.screensaver:ubuntu]
picture-uri = 'file:///usr/share/backgrounds/warty-final-ubuntu.png'

[org.gnome.desktop.interface:ubuntu]
gtk-theme = "Yaru-blue-dark"
icon-theme = "Yaru-blue"
cursor-theme = "Yaru"
font-name = "Ubuntu Sans 11"
monospace-font-name = "Ubuntu Sans Mono 13"
document-font-name = "Sans 11"
enable-hot-corners = false
font-antialiasing = 'rgba'

[com.ubuntu.update-notifier:ubuntu]
notify-ubuntu-advantage-available = true

[org.gtk.Settings.FileChooser:ubuntu]
sort-directories-first = true
startup-mode = 'cwd'

# Mirror G-S default experience (in overrides) compared to mutter default
# as we are using a G-S mode, the default overrides aren't used.
[org.gnome.mutter:ubuntu]
attach-modal-dialogs = true
edge-tiling = true
dynamic-workspaces = true
workspaces-only-on-primary = true
focus-change-on-pointer-rest = true

[org.gnome.desktop.peripherals.touchpad:ubuntu]
tap-to-click = true
click-method = 'default'

[org.gnome.desktop.wm.keybindings:ubuntu]
show-desktop = ['<Primary><Super>d','<Primary><Alt>d','<Super>d']
switch-applications = ['<Super>Tab']
switch-windows = ['<Alt>Tab']
switch-applications-backward = ['<Shift><Super>Tab']
switch-windows-backward = ['<Shift><Alt>Tab']

[org.gnome.desktop.wm.preferences:ubuntu]
button-layout = 'close,minimize,maximize:'
titlebar-font = 'Ubuntu Sans Bold 11'
titlebar-uses-system-font = false
action-middle-click-titlebar = 'lower'

[org.gnome.Empathy.conversation:ubuntu]
theme = "adium"
theme-variant = "Normal"
adium-path = "/usr/share/adium/message-styles/ubuntu.AdiumMessageStyle"

[org.gnome.nautilus.desktop:ubuntu]
home-icon-visible = false

[org.gnome.nautilus.icon-view:ubuntu]
default-zoom-level = 'small'

[org.gnome.shell.extensions.desktop-icons:ubuntu]
icon-size = 'small'

[org.gnome.nautilus.preferences:ubuntu]
open-folder-on-dnd-hover = false

[org.gnome.rhythmbox.plugins:ubuntu]
active-plugins = ['alternative-toolbar', 'artsearch', 'audiocd','audioscrobbler','cd-recorder','daap','dbus-media-server','generic-player','ipod','iradio','mmkeys','mpris','mtpdevice','notification','power-manager']

[org.gnome.rhythmbox.plugins.alternative_toolbar:ubuntu]
display-type=1

[org.gnome.settings-daemon.plugins.print-notifications:ubuntu]
active = false

[org.gnome.settings-daemon.plugins.background:ubuntu]
active = false

[org.gnome.Terminal.Legacy.Settings:ubuntu]
theme-variant = 'dark'

##########################
# unity specific session #
##########################

[org.gnome.desktop.wm.preferences:Unity]
button-layout = 'close,minimize,maximize:'
mouse-button-modifier = '<Alt>'

[org.gnome.nautilus.desktop:Unity]
trash-icon-visible = false
volumes-visible = false

[org.cinnamon.desktop.media-handling:Unity]
automount = false
automount-open = false

[org.gnome.desktop.interface:Unity]
gtk-theme = "Ambiance"
icon-theme = "ubuntu-mono-dark"
cursor-theme = "DMZ-White"

[org.gnome.desktop.wm.keybindings:Unity]
maximize = ['<Primary><Super>Up','<Super>Up','<Primary><Alt>KP_5']
minimize = ['<Primary><Alt>KP_0']
move-to-corner-ne = ['<Primary><Alt>KP_Prior']
move-to-corner-nw = ['<Primary><Alt>KP_Home']
move-to-corner-se = ['<Primary><Alt>KP_Next']
move-to-corner-sw = ['<Primary><Alt>KP_End']
move-to-side-e = ['<Primary><Alt>KP_Right']
move-to-side-n = ['<Primary><Alt>KP_Up']
move-to-side-s = ['<Primary><Alt>KP_Down']
move-to-side-w = ['<Primary><Alt>KP_Left']
toggle-maximized = ['<Primary><Alt>KP_5']
unmaximize = ['<Primary><Super>Down','<Super>Down','<Alt>F5']

[org.gnome.settings-daemon.plugins.background:Unity]
active = true

[org.gnome.Terminal.Legacy.Settings:Unity]
headerbar = false

[com.canonical.unity.settings-daemon.plugins.power]
button-power = 'interactive'
button-sleep = 'suspend'
critical-battery-action = 'suspend'

#############################################
# communitheme specific session for testers #
#############################################

[org.gnome.desktop.interface:communitheme]
cursor-theme = "communitheme"
icon-theme = "Suru"
gtk-theme = "Communitheme"

[org.gnome.desktop.sound:communitheme]
theme-name = "communitheme"
EOF

	cat <<EOF > /usr/share/glib-2.0/schemas/org.gnome.Terminal.gschema.xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright © 2002 Havoc Pennington
  Copyright © 2002 Jonathan Blandford
  Copyright © 2003, 2004 Mariano Suárez-Alvarez
  Copyright © 2005 Kjartan Maraas
  Copyright © 2005 Tony Tsui
  Copyright © 2006 Guilherme de S. Pastore
  Copyright © 2009, 2010 Behdad Esfahbod
  Copyright © 2008, 2010 Christian Persch

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->
<schemalist gettext-domain="gnome-terminal">

   <enum id='org.gnome.Terminal.NewTerminalMode'>
    <value nick='window' value='0'/>
    <value nick='tab' value='1'/>
  </enum>

  <enum id='org.gnome.Terminal.NewTabPosition'>
    <value nick='last' value='0'/>
    <value nick='next' value='1'/>
  </enum>

   <enum id='org.gnome.Terminal.ScrollbarPolicy'>
    <value nick='always' value='0'/>
    <!-- <value nick='automatic' value='1'/> -->
    <value nick='never' value='2'/>
  </enum>

   <enum id='org.gnome.Terminal.TabsbarPolicy'>
    <value nick='always' value='0'/>
    <value nick='automatic' value='1'/>
    <!-- <value nick='never' value='2'/> -->
  </enum>

   <enum id='org.gnome.Terminal.ThemeVariant'>
    <value nick='system' value='0'/>
    <value nick='light'  value='1'/>
    <value nick='dark'   value='2'/>
  </enum>

  <enum id='org.gnome.Terminal.ExitAction'>
    <value nick='close' value='0'/>
    <value nick='restart' value='1'/>
    <value nick='hold' value='2'/>
  </enum>

  <enum id='org.gnome.Terminal.CJKWidth'>
    <value nick='narrow' value='1'/>
    <value nick='wide'   value='2'/>
  </enum>

  <enum id="org.gnome.Terminal.PreserveWorkingDirectory">
    <value nick="never"  value='0'/>
    <value nick="safe"   value='1'/>
    <value nick="always" value='2'/>
  </enum>

  <!-- From gtk+ -->
  <enum id="org.gnome.Terminal.TabPosition">
    <!-- <value nick="left"   value="0" /> -->
    <!-- <value nick="right"  value="1" /> -->
    <value nick="top"    value="2" />
    <value nick="bottom" value="3" />
  </enum>

  <!-- These really belong into some vte-built enums file, but
        using enums from other modules still has some
        problems. Just include a copy here for now.
    -->
  <enum id='org.gnome.Terminal.EraseBinding'>
    <value nick='auto' value='0'/>
    <value nick='ascii-backspace' value='1'/>
    <value nick='ascii-delete' value='2'/>
    <value nick='delete-sequence' value='3'/>
    <value nick='tty' value='4'/>
  </enum>
  <enum id='org.gnome.Terminal.Cursor.BlinkMode'>
    <value nick='system' value='0'/>
    <value nick='on' value='1'/>
    <value nick='off' value='2'/>
  </enum>
  <enum id='org.gnome.Terminal.Cursor.Shape'>
    <value nick='block' value='0'/>
    <value nick='ibeam' value='1'/>
    <value nick='underline' value='2'/>
  </enum>
  <enum id='org.gnome.Terminal.TextBlinkMode'>
    <value nick='never' value='0'/>
    <value nick='focused' value='1'/>
    <value nick='unfocused' value='2'/>
    <value nick='always' value='3'/>
  </enum>

  <!-- SettingsList base schema -->

  <schema id="org.gnome.Terminal.SettingsList">
    <key name="list" type="as">
      <default>[]</default>
    </key>
    <key name="default" type="s">
      <default>''</default>
    </key>
  </schema>

  <!-- Profiles list schema -->

  <schema id="org.gnome.Terminal.ProfilesList" 
          extends="org.gnome.Terminal.SettingsList"
          path="/org/gnome/terminal/legacy/profiles:/">
    <override name="list">['b1dcc9dd-5262-4d8d-a863-c897e6d979b9']</override>
    <override name="default">'b1dcc9dd-5262-4d8d-a863-c897e6d979b9'</override>
  </schema>

  <!-- A terminal profile -->

  <schema id="org.gnome.Terminal.Legacy.Profile">
    <key name="visible-name" type="s">
      <!-- Translators: This needs to be parsed as a GVariant string, so keep the regular single quotes around the string as-is, and do not add extra quotes. -->
      <default l10n="messages" context="visible-name">'UFS'</default>
      <summary>Human-readable name of the profile</summary>
      <description>Human-readable name of the profile.</description>
    </key>
    <key name="foreground-color" type="s">
      <default>'#00FF00'</default>
      <summary>Default color of text in the terminal</summary>
      <description>Default color of text in the terminal, as a color specification (can be HTML-style hex digits, or a color name such as “red”).</description>
    </key>
    <key name="background-color" type="s">
      <default>'#000000'</default>
      <summary>Default color of terminal background</summary>
      <description>Default color of terminal background, as a color specification (can be HTML-style hex digits, or a color name such as “red”).</description>
    </key>
    <key name="bold-color" type="s">
      <default>'#000000'</default>
      <summary>Default color of bold text in the terminal</summary>
      <description>Default color of bold text in the terminal, as a color specification (can be HTML-style hex digits, or a color name such as “red”). This is ignored if bold-color-same-as-fg is true.</description>
    </key>
    <key name="bold-color-same-as-fg" type="b">
      <default>true</default>
      <summary>Whether bold text should use the same color as normal text</summary>
      <description>If true, boldface text will be rendered using the same color as normal text.</description>
    </key>
    <key name="cell-height-scale" type="d">
      <range min="1.0" max="2.0" />
      <default>1.0</default>
      <summary>Scale factor for the cell height to increase line spacing. (Does not increase the font’s height.)</summary>
    </key>
    <key name="cell-width-scale" type="d">
      <range min="1.0" max="2.0" />
      <default>1.0</default>
      <summary>Scale factor for the cell width to increase letter spacing. (Does not increase the font’s width.)</summary>
    </key>
    <key name="cursor-colors-set" type="b">
      <default>false</default>
      <summary>Whether to use custom cursor colors</summary>
      <description>If true, use the cursor colors from the profile.</description>
    </key>
    <key name="cursor-background-color" type="s">
      <default>'#000000'</default>
      <summary>Cursor background color</summary>
      <description>Custom color of the background of the terminal’s cursor, as a color specification (can be HTML-style hex digits, or a color name such as “red”). This is ignored if cursor-colors-set is false.</description>
    </key>
    <key name="cursor-foreground-color" type="s">
      <default>'#ffffff'</default>
      <summary>Cursor foreground colour</summary>
      <description>Custom color for the foreground of the text character at the terminal’s cursor position, as a color specification (can be HTML-style hex digits, or a color name such as “red”). This is ignored if cursor-colors-set is false.</description>
    </key>
    <key name="highlight-colors-set" type="b">
      <default>false</default>
      <summary>Whether to use custom highlight colors</summary>
      <description>If true, use the highlight colors from the profile.</description>
    </key>
    <key name="highlight-background-color" type="s">
      <default>'#000000'</default>
      <summary>Highlight background color</summary>
      <description>Custom color of the background of the terminal’s highlight, as a color specification (can be HTML-style hex digits, or a color name such as “red”). This is ignored if highlight-colors-set is false.</description>
    </key>
    <key name="highlight-foreground-color" type="s">
      <default>'#ffffff'</default>
      <summary>Highlight foreground colour</summary>
      <description>Custom color for the foreground of the text character at the terminal’s highlight position, as a color specification (can be HTML-style hex digits, or a color name such as “red”). This is ignored if highlight-colors-set is false.</description>
    </key>
    <key name="enable-bidi" type="b">
      <default>true</default>
      <summary>Whether to perform bidirectional text rendering</summary>
      <description>If true, perform bidirectional text rendering (“BiDi”).</description>
    </key>
    <key name="enable-shaping" type="b">
      <default>true</default>
      <summary>Whether to perform Arabic shaping</summary>
      <description>If true, shape Arabic text.</description>
    </key>
    <key name="enable-sixel" type="b">
      <default>false</default>
      <summary>Whether to enable SIXEL images</summary>
      <description>If true, SIXEL sequences are parsed and images are rendered.</description>
    </key>
    <key name="bold-is-bright" type="b">
      <default>true</default>
      <summary>Whether bold is also bright</summary>
      <description>If true, setting bold on the first 8 colors also switches to their bright variants.</description>
    </key>
    <key name="audible-bell" type="b">
      <default>true</default>
      <summary>Whether to ring the terminal bell</summary>
    </key>
    <key name="word-char-exceptions" type="ms">
      <default>nothing</default>
      <summary>List of punctuation characters that are treated as word characters</summary>
      <description>By default, when doing word-wise selection, most punctuation breaks up word boundaries. This list of exceptions will instead be treated as part of the word.</description>
    </key>
    <key name="default-size-columns" type="i">
      <range min="16" max="511" />
      <default>90</default>
      <summary>Default number of columns</summary>
      <description>Number of columns in newly created terminal windows. Has no effect if use_custom_default_size is not enabled.</description>
    </key>
    <key name="default-size-rows" type="i">
      <range min="4" max="511" />
      <default>36</default>
      <summary>Default number of rows</summary>
      <description>Number of rows in newly created terminal windows. Has no effect if use_custom_default_size is not enabled.</description>
    </key>
    <key name="scrollbar-policy" enum="org.gnome.Terminal.ScrollbarPolicy">
      <default>'always'</default>
      <summary>When to show the scrollbar</summary>
    </key>
    <key name="scrollback-lines" type="i">
      <default>10000</default>
      <summary>Number of lines to keep in scrollback</summary>
      <description>Number of scrollback lines to keep around. You can scroll back in the terminal by this number of lines; lines that don’t fit in the scrollback are discarded. If scrollback_unlimited is true, this value is ignored.</description>
    </key>
    <key name="scrollback-unlimited" type="b">
      <default>false</default>
      <summary>Whether an unlimited number of lines should be kept in scrollback</summary>
      <description>If true, scrollback lines will never be discarded. The scrollback history is stored on disk temporarily, so this may cause the system to run out of disk space if there is a lot of output to the terminal.</description>
    </key>
    <key name="scroll-on-insert" type="b">
      <default>true</default>
      <summary>Whether to scroll to the bottom when text is inserted</summary>
      <description>If true, the terminal will scroll to the bottom when text is inserted by paste.</description>
    </key>
    <key name="scroll-on-keystroke" type="b">
      <default>true</default>
      <summary>Whether to scroll to the bottom when a key is pressed</summary>
      <description>If true, pressing a key jumps the scrollbar to the bottom.</description>
    </key>
    <key name="scroll-on-output" type="b">
      <default>false</default>
      <summary>Whether to scroll to the bottom when there’s new output</summary>
      <description>If true, whenever there’s new output the terminal will scroll to the bottom.</description>
    </key>
    <key name="exit-action" enum="org.gnome.Terminal.ExitAction">
      <default>'close'</default>
      <summary>What to do with the terminal when the child command exits</summary>
      <description>Possible values are “close” to close the terminal, “restart” to restart the command, and “hold” to keep the terminal open with no command running inside.</description>
    </key>
    <key name="login-shell" type="b">
      <default>false</default>
      <summary>Whether to launch the command in the terminal as a login shell</summary>
      <description>If true, the command inside the terminal will be launched as a login shell (argv[0] will have a hyphen in front of it).</description>
    </key>
    <key name="preserve-working-directory" enum="org.gnome.Terminal.PreserveWorkingDirectory">
      <default>'safe'</default>
      <summary>Whether to preserve the working directory when opening a new terminal</summary>
      <description>
        Controls when opening a new terminal from a previous one carries over the working directory of the opening terminal to the new one.
      </description>
    </key>
    <key name="use-custom-command" type="b">
      <default>false</default>
      <summary>Whether to run a custom command instead of the shell</summary>
      <description>If true, the value of the custom_command setting will be used in place of running a shell.</description>
    </key>
    <key name="cursor-blink-mode" enum="org.gnome.Terminal.Cursor.BlinkMode">
      <default>'system'</default>
      <summary>Whether to blink the cursor</summary>
      <description>The possible values are “system” to use the global cursor blinking settings, or “on” or “off” to set the mode explicitly.</description>
    </key>
    <key name="cursor-shape" enum="org.gnome.Terminal.Cursor.Shape">
      <default>'block'</default>
      <summary>The cursor appearance</summary>
    </key>
    <key name="text-blink-mode" enum="org.gnome.Terminal.TextBlinkMode">
      <default>'always'</default>
      <summary>Possible values are “always” or “never” allow blinking text, or only when the terminal is “focused” or “unfocused”.</summary>
    </key>
    <key name="custom-command" type="s">
      <default>''</default>
      <summary>Custom command to use instead of the shell</summary>
      <description>Run this command in place of the shell, if use_custom_command is true.</description>
    </key>
    <key name="palette" type="as">
      <default>['#171421',
                '#c01c28',
                '#26a269',
                '#a2734c',
                '#12488b',
                '#a347ba',
                '#2aa1b3',
                '#d0cfcc',
                '#5e5c64',
                '#f66151',
                '#33da7a',
                '#e9ad0c',
                '#2a7bde',
                '#c061cb',
                '#33c7de',
                '#ffffff']</default>
      <summary>Palette for terminal applications</summary>
    </key>
    <key name="font" type="s">
      <default>'Monospace 12'</default>
      <summary>A Pango font name and size</summary>
    </key>
    <key name="backspace-binding" enum="org.gnome.Terminal.EraseBinding">
      <default>'ascii-delete'</default>
      <summary>The code sequence the Backspace key generates</summary>
    </key>
    <key name="delete-binding" enum="org.gnome.Terminal.EraseBinding">
      <default>'delete-sequence'</default>
      <summary>The code sequence the Delete key generates</summary>
    </key>
    <key name="use-theme-colors" type="b">
      <default>false</default>
      <summary>Whether to use the colors from the theme for the terminal widget</summary>
    </key>
    <key name="use-system-font" type="b">
      <default>true</default>
      <summary>Whether to use the system monospace font</summary>
    </key>
    <key name="rewrap-on-resize" type="b">
      <default>true</default>
      <summary>Whether to rewrap the terminal contents on window resize</summary>
    </key>
    <key name="encoding" type="s">
      <default>'UTF-8'</default>
      <summary>Which encoding to use</summary>
    </key>
    <key name="cjk-utf8-ambiguous-width" enum="org.gnome.Terminal.CJKWidth">
      <default>'narrow'</default>
      <summary>Whether ambiguous-width characters are narrow or wide when using UTF-8 encoding</summary>
    </key>
    <key name="use-transparent-background" type="b">
      <default>true</default>
      <summary>Whether to use a transparent background</summary>
    </key>
    <key name="use-theme-transparency" type="b">
      <default>false</default>
      <summary>Whether to use the value of TerminalScreen-background-darkness,
          if available, from the theme for the transparency value.</summary>
    </key>
    <key name="background-transparency-percent" type="i">
      <default>9</default>
      <summary>Adjust the amount of transparency</summary>
      <description>A value between 0 and 100, where 0 is opaque and 100 is fully transparent.</description>
    </key>
  </schema>

  <!-- Keybinding settings -->

  <schema id="org.gnome.Terminal.Legacy.Keybindings">
    <key name="new-tab" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;t'</default>
      <summary>Keyboard shortcut to open a new tab</summary>
    </key>
    <key name="new-window" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;n'</default>
      <summary>Keyboard shortcut to open a new window</summary>
    </key>
    <key name="save-contents" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to save the current tab contents to file</summary>
    </key>
    <key name="export" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to export the current tab contents to file in various formats</summary>
    </key>
    <key name="print" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to print the current tab contents to printer or file</summary>
    </key>
    <key name="close-tab" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;w'</default>
      <summary>Keyboard shortcut to close a tab</summary>
    </key>
    <key name="close-window" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;q'</default>
      <summary>Keyboard shortcut to close a window</summary>
    </key>
    <key name="copy" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;c'</default>
      <summary>Keyboard shortcut to copy text</summary>
    </key>
    <key name="copy-html" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to copy text as HTML</summary>
    </key>
    <key name="paste" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;v'</default>
      <summary>Keyboard shortcut to paste text</summary>
    </key>
    <key name="select-all" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to select all text</summary>
    </key>
    <key name="preferences" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to open the Preferences dialog</summary>
    </key>
    <key name="full-screen" type="s">
      <default>'F11'</default>
      <summary>Keyboard shortcut to toggle full screen mode</summary>
    </key>
    <key name="toggle-menubar" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to toggle the visibility of the menubar</summary>
    </key>
    <key name="read-only" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to toggle the read-only state</summary>
    </key>
    <key name="reset" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to reset the terminal</summary>
    </key>
    <key name="reset-and-clear" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to reset and clear the terminal</summary>
    </key>
    <key name="find" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;F'</default>
      <summary>Keyboard shortcut to open the search dialog</summary>
    </key>
    <key name="find-next" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;G'</default>
      <summary>Keyboard shortcut to find the next occurrence of the search term</summary>
    </key>
    <key name="find-previous" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;H'</default>
      <summary>Keyboard shortcut to find the previous occurrence of the search term</summary>
    </key>
    <key name="find-clear" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;J'</default>
      <summary>Keyboard shortcut to clear the find highlighting</summary>
    </key>
    <key name="prev-tab" type="s">
      <default>'&lt;Control&gt;Page_Up'</default>
      <summary>Keyboard shortcut to switch to the previous tab</summary>
    </key>
    <key name="next-tab" type="s">
      <default>'&lt;Control&gt;Page_Down'</default>
      <summary>Keyboard shortcut to switch to the next tab</summary>
    </key>
    <key name="move-tab-left" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;Page_Up'</default>
      <summary>Keyboard shortcut to move the current tab to the left</summary>
    </key>
    <key name="move-tab-right" type="s">
      <default>'&lt;Control&gt;&lt;Shift&gt;Page_Down'</default>
      <summary>Keyboard shortcut to move the current tab to the right</summary>
    </key>
    <key name="detach-tab" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to detach current tab</summary>
    </key>
    <key name="switch-to-tab-1" type="s">
      <default>'&lt;Alt&gt;1'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-2" type="s">
      <default>'&lt;Alt&gt;2'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-3" type="s">
      <default>'&lt;Alt&gt;3'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-4" type="s">
      <default>'&lt;Alt&gt;4'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-5" type="s">
      <default>'&lt;Alt&gt;5'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-6" type="s">
      <default>'&lt;Alt&gt;6'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-7" type="s">
      <default>'&lt;Alt&gt;7'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-8" type="s">
      <default>'&lt;Alt&gt;8'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-9" type="s">
      <default>'&lt;Alt&gt;9'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-10" type="s">
      <default>'&lt;Alt&gt;0'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-11" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-12" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-13" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-14" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-15" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-16" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-17" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-18" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-19" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-20" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-21" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-22" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-23" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-24" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-25" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-26" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-27" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-28" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-29" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-30" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-31" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-32" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-33" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-34" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-35" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the numbered tab</summary>
    </key>
    <key name="switch-to-tab-last" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to switch to the last tab</summary>
    </key>
    <key name="help" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to launch help</summary>
    </key>
    <key name="zoom-in" type="s">
      <default>'&lt;Control&gt;plus'</default>
      <summary>Keyboard shortcut to make font larger</summary>
    </key>
    <key name="zoom-out" type="s">
      <default>'&lt;Control&gt;minus'</default>
      <summary>Keyboard shortcut to make font smaller</summary>
    </key>
    <key name="zoom-normal" type="s">
      <default>'&lt;Control&gt;0'</default>
      <summary>Keyboard shortcut to make font normal-size</summary>
    </key>
    <key name="header-menu" type="s">
      <default>'disabled'</default>
      <summary>Keyboard shortcut to show the primary menu</summary>
    </key>
  </schema>

  <!-- Global settings -->

  <schema id="org.gnome.Terminal.Legacy.Settings" path="/org/gnome/terminal/legacy/">

    <key name="mnemonics-enabled" type="b">
      <default>false</default>
      <summary>Whether the menubar has access keys</summary>
      <description>
        Whether to have Alt+letter access keys for the menubar.
        They may interfere with some applications run inside the terminal
        so it’s possible to turn them off.
      </description>
    </key>

    <key name="shortcuts-enabled" type="b">
      <default>true</default>
      <summary>Whether shortcuts are enabled</summary>
      <description>
        Whether shortcuts are enabled.
        They may interfere with some applications run inside the terminal
        so it’s possible to turn them off.
      </description>
    </key>

    <key name="menu-accelerator-enabled" type="b">
      <default>true</default>
      <summary>Whether the standard GTK shortcut for menubar access is enabled</summary>
      <description>
        Normally you can access the menubar with F10. This can also
        be customized via gtkrc (gtk-menu-bar-accel =
        "whatever"). This option allows the standard menubar
        accelerator to be disabled.
      </description>
    </key>

    <key name="shell-integration-enabled" type="b">
      <default>true</default>
      <summary>Whether the shell integration is enabled</summary>
    </key>

    <key name="confirm-close" type="b">
      <default>true</default>
      <summary>Whether to ask for confirmation before closing a terminal</summary>
    </key>

    <key name="context-info" type="as">
      <default>['numbers']</default>
      <summary>Additional info section items to appear in the context menu</summary>
    </key>

    <key name="default-show-menubar" type="b">
      <default>true</default>
      <summary>Whether to show the menubar in new windows</summary>
    </key>

    <key name="new-terminal-mode" enum="org.gnome.Terminal.NewTerminalMode">
      <default>'window'</default>
      <summary>Whether to open new terminals as windows or tabs</summary>
    </key>

    <key name="tab-policy" enum="org.gnome.Terminal.TabsbarPolicy">
      <default>'automatic'</default>
      <summary>When to show the tabs bar</summary>
    </key>

    <key name="tab-position" enum="org.gnome.Terminal.TabPosition">
      <default>'top'</default>
      <summary>The position of the tab bar</summary>
    </key>

    <key name="theme-variant" enum="org.gnome.Terminal.ThemeVariant">
      <default>'system'</default>
      <summary>Which theme variant to use</summary>
    </key>

    <key name="new-tab-position" enum="org.gnome.Terminal.NewTabPosition">
      <default>'last'</default>
      <summary>Whether new tabs should open next to the current one or at the last position</summary>
    </key>

    <!-- Default terminal -->

    <key name="always-check-default-terminal" type="b">
      <default>true</default>
      <summary>Always check whether GNOME Terminal is the default terminal</summary>
    </key>

    <!-- Note that changing the following settings will only take effect
         when gnome-terminal-server is restarted.
    -->

    <key name="headerbar" type="mb">
      <default>nothing</default>
    </key>

    <key name="unified-menu" type="b">
      <default>true</default>
    </key>

   <!-- <child name="profiles" schema="org.gnome.Terminal.ProfilesList" /> -->

   <child name="keybindings" schema="org.gnome.Terminal.Legacy.Keybindings" />

   <key name="schema-version" type="u">
     <default>3</default>
   </key>

  </schema>

</schemalist>	
EOF

rm /usr/share/glib-2.0/schemas/gschemas.compiled

glib-compile-schemas /usr/share/glib-2.0/schemas
    
    # purge
    apt-get purge -y \
    transmission-gtk \
    transmission-common \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    aisleriot \
    hitori
}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.4"
