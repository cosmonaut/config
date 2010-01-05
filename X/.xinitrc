#!/usr/bin/env/ bash

if [ -f $HOME/.Xdefaults ]; then
    xrdb -merge $HOME/.Xdefaults
fi

# Set keys to be the syms I want
#xmodmap /home/tron/.config/awesome/keys.modmap
# run processes for certain binds. (right click!)
#xbindkeys

# for now this seems to murder awesome
# xcompmgr &

xsetroot -solid black &

#xrandr --output LVDS --right-of DVI-0 --auto
#xrandr --output LVDS --off
#xrandr --output LVDS --right-of DVI-0 --auto

#feh --bg-center /home/tron/Desktop/storm_lo.jpg
#feh --bg-center /home/tron/Desktop/storm_lo.jpg
#python /home/tron/.config/awesome/bat.py &

#exec /usr/bin/dwm
exec /usr/bin/awesome
