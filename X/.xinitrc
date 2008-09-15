#!/bin/bash

cd $HOME

if [ -f $HOME/.Xdefaults ]; then
    xrdb -merge $HOME/.Xdefaults
fi

xsetroot -solid black

eval `cat /home/nnell/.fehbg` &

/home/nnell/bin/awesome-clock &
exec /usr/bin/awesome
