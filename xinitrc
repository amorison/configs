setxkbmap fr
numlockx
xbacklight -set 10
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
xcompmgr &
sxhkd &
exec bspwm
