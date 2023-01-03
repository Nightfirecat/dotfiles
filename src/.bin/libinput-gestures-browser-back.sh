#!/usr/bin/env bash

###
### An xdotools composing script to detect whether the active window is a
### browser (tested against Firefox and Chromium) and, if so, send a Backspace
### to it to attempt to navigate to the previous page.
### This is no longer used as activating precise scrolling via adding
### `MOZ_USE_XINPUT2=1` to `/etc/environment` fixes 2-finger scrolling
### activating previous and next page behavior in Firefox.
### See: https://askubuntu.com/a/1149543/464000
###

wid="$(
	comm -12 \
		<(xdotool getactivewindow) \
		<(cat \
			<(xdotool search --classname Navigator) \
			<(xdotool search --classname chromium) \
		| sort)
)"
if [ -n "$wid" ]; then
	xdotool key --window "$wid" BackSpace
fi
