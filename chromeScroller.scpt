#!/usr/bin/osascript

# applescript that lets me scroll the active google chrome window up/down from the terminal.
# useful for, say, coding while reading documentation/tutorials without having to constantly move
# to the browser to scroll around. Map this to vim/tmux commands to make it easy to use.

on run argv
	set PAGE_UP to 116
	set PAGE_DOWN to 121
	set HOME to 115
	set KB_END to 119
	set LEFT_ARROW to 123
	set RIGHT_ARROW to 124
	set DOWN_ARROW to 125
	set UP_ARROW to 126


	set prevApp to path to frontmost application as text
	-- prevApp is something like "Macintosh HS:Applications:Utilities:Terminal.app:"
	-- log "prevApp is [" & prevApp & "]"

	-- split based on colons, get second-to-last element, then cut based on dot and take the application name
	-- why second-to-last? Because there's a trailing colon on prevApp for whatever reason.
	set cleanAppName to do shell script "echo " & (quoted form of prevApp) & " | awk '{ arrLen=split($0, arr, \":\")} END{ print arr[arrLen-1]}' | cut -d'.' -f1"

	-- log "cleanAppName is [" & cleanAppName & "]"
	-- cleanAppName is something like "Terminal"


	if (length of argv is not 1) then
		-- if nothing was passed in, scroll down
		set desiredScrollAction to DOWN_ARROW
	else
		-- otherwise, map "up" to the up arrow code, etc.
		set scrollDescriptor to item 1 of argv
		if (scrollDescriptor = "up")
			set desiredScrollAction to UP_ARROW
		else if (scrollDescriptor = "down")
			set desiredScrollAction to DOWN_ARROW
		else if (scrollDescriptor = "pageup")
			set desiredScrollAction to PAGE_UP
		else if (scrollDescriptor = "pagedown")
			set desiredScrollAction to PAGE_DOWN
		end if
	end if
	-- log "scrolling [" & desiredScrollAction & "]..."
		
	-- must bring chrome to forefront (maybe make process configurable? See if this is even useful...
	tell application "System Events" to tell process "Google Chrome"
		set frontmost to true
		perform action "AXRaise" of window 1

		-- and now actually scroll in the desired direction by simulating an up/down/left/right arrowkey press
		key code desiredScrollAction
	end tell

	-- log "about to return to previous app..."
	-- finally, alt-tab back to previous app
	-- tell application "System Events" to keystroke tab using command down
	
	-- alt-tab works fine as normal shell script but when mapped as a tmux binding it fails for some reason.
	-- so instead we'll just re-raise the cleanAppName...
	tell application "System Events" to tell process cleanAppName to set frontmost to true

end run
