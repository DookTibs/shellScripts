#!/usr/bin/env osascript


-- takes the name of a Airfoil speaker and an optional command (defaults to "toggle")
-- e.g. "osascript getCurrentPlayingSong.applescript"

on run argv
	tell application "Spotify"
		set t to the current track

		if ("" & player state) is "playing" then
			-- log "" & album artist of t
			-- log "" & album of t
			-- log "" & name of t
			log album artist of t & ": " & name of t
		else
			-- log "currently " & player state
			log "Spotify not playing..."
		end if
	end tell
	
end run

