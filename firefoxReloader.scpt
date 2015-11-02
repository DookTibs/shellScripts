#!/usr/bin/osascript
--test script
-- see http://superuser.com/questions/435288/how-to-open-a-new-firefox-window-with-url-argument

-- used http://stackoverflow.com/questions/12358270/closing-specific-tab-in-firefox-using-applescript
-- and http://stackoverflow.com/questions/263741/using-applescript-to-grab-the-url-from-the-frontmost-window-in-web-browsers-the
-- any way to get the URL instead of the name? YES, implemented below - need to use the clipboard...

-- todo: support regexes? make it work for a configurable browser?
-- open new window/tab if one to reload isn't found?

on run argv
	if (length of argv is not 1) then
		log "invalid usage"
		return
	end if
	set urlPattern to item 1 of argv
	set savedClipboardData to the clipboard

	set looper to 0
	set MAX_LOOPER to 15
	tell application "System Events" to tell process "firefox"
		set frontmost to true
		repeat with w from 1 to count of windows
			perform action "AXRaise" of window w
			set startTab to name of window 1
			repeat
				set looper to looper + 1

				-- once during testing i got in an infinite loop somehow. just in case...
				if (looper >= MAX_LOOPER) then
					exit repeat
				end if
				
				keystroke "l" using {command down} -- Highlight the URL field.
				keystroke "c" using {command down}
				delay 0.1
				set currentUrl to (the clipboard as text)
				
				if (currentUrl) contains urlPattern then
					keystroke "r" using command down
					exit repeat
				else
					keystroke "}" using command down
				end if

				delay 0.1
				if name of window 1 is startTab then exit repeat
			end repeat
		end repeat
	end tell
	set the clipboard to savedClipboardData
	-- log "clipboard is now " & (the clipboard as text)

	-- alt-tab back to the app we called this script from
	tell application "System Events" to keystroke tab using command down
end run
