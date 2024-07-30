#!/usr/bin/env osascript

-- shell script that takes a command like "thumbup", "playpause", and operates
-- on Pandora.

-- uses the nice "sendkeys" tool:
--     brew install socsieng/tap/sendkeys
-- PLAY/PAUSE
-- sendkeys --application-name "Pandora" --characters "<c:space>"
-- 
-- SKIP
-- sendkeys --application-name "Pandora" --characters "<c:right:command>"
-- 
-- REPLAY
-- sendkeys --application-name "Pandora" --characters "<c:left:command>"
-- 
-- THUMBUP
-- sendkeys --application-name 'Pandora' --characters '<c:up:command,shift>'
-- 
-- THUMBDOWN
-- sendkeys --application-name "Pandora" --characters "<c:down:command,shift>"


-- I couldn't get this working...
-- https://forum.latenightsw.com/t/what-is-applescript-equivalent-to-javascript-associative-arrays/2021/4
-- set SUPPORTED_COMMANDS to dictFromList({{"thumbup", "<c:up:command,shift>"}, {"playpause", "<c:space>"}})
-- keys(SUPPORTED_COMMANDS)
-- elems(SUPPORTED_COMMANDS)
-- assocs(SUPPORTED_COMMANDS)

on run argv
	-- log "in argv: [" & (argv as text) & ":]"
	-- log class of argv
	-- log count of argv

	set active_app to ""
	tell application "System Events"
		set active_app to (name of application processes whose frontmost is true) as text
	end tell

	set LEGAL_COMMANDS to { "playpause", "skip", "replay", "thumbup", "thumbdown" }

	if count of argv >= 1 then
		set pandora_cmd to item 1 of argv

		if LEGAL_COMMANDS contains pandora_cmd then
			-- start / bring Pandora to foreground
			tell application "Pandora" to activate

			-- https://eastmanreference.com/complete-list-of-applescript-key-codes

			tell application "System Events"
				-- key code 124 using {command down}
				if pandora_cmd equals "thumbup" then
					-- "do shell script" works if I run via e.g. osascript. But fails when runnign via Stream Deck?
					-- do shell script "sendkeys --application-name 'Pandora' --characters '<c:up:command,shift>'"
					key code 126 using {command down, shift down}
				else if pandora_cmd equals "thumbdown" then
					-- do shell script "sendkeys --application-name 'Pandora' --characters '<c:down:command,shift>'"
					key code 125 using {command down, shift down}
				else if pandora_cmd equals "playpause" then
					-- do shell script "sendkeys --application-name 'Pandora' --characters '<c:space>'"
					key code 49 -- spacebar
				else if pandora_cmd equals "skip" then
					-- do shell script "sendkeys --application-name 'Pandora' --characters '<c:right:command>'"
					key code 124 using {command down}
				else if pandora_cmd equals "replay" then
					-- do shell script "sendkeys --application-name 'Pandora' --characters '<c:left:command>'"
					key code 123 using {command down}
				end if
				
				if active_app is not equal to "Pandora" then
					-- alt-tab back to the previous app
					key code 48 using {command down}
				end if
			end tell
		end if

	end if
	
end run

