#!/usr/bin/env osascript

-- takes the name of a Airfoil speaker and an optional command (defaults to "toggle")
-- e.g. "osascript airfoilSpeakerToggle.sh 'Feiler Blue HomePod Mini' 'off'"

on run argv
	-- commandline argument processing: START
	-- log (count of argv as text) & " args:"

	-- speakers
	set speakerName to null
	set volumeCmd to null
	set activationCmd to null
	set singleSpeakerLogic to false

	-- source
	set sourceName to null
	repeat with argi from 1 to length of argv
		set arg to item argi of argv
		-- log ">>> [" & argi & "] [" & arg & "] [" & (class of argi) & "]"

		if arg is equal to "-s" then
			if argi < (count of argv) then
				set speakerName to (item (argi + 1) of argv)
			end if
		else if arg is equal to "-v" then
			if argi < (count of argv) then
				set volumeCmd to (item (argi + 1) of argv)
			end if
		else if arg is equal to "-c" then
			if argi < (count of argv) then
				set activationCmd to (item (argi + 1) of argv)
			end if
		else if arg is equal to "-a" then
			if argi < (count of argv) then
				set sourceName to (item (argi + 1) of argv)
			end if
		else if arg is equal to "-x" then
			set singleSpeakerLogic to true
		end if
	end repeat
	-- commandline argument processing: END

	if speakerName is not null
		-- log "PROCEED: speaker=[" & speakerName & "]; vol=[" & volumeCmd & "]; activation=[" & activationCmd & "]; source=[" & sourceName & "]; singleLogic=[" & singleSpeakerLogic & "]"

		tell application "Airfoil"
			set targetSpeaker to null
			set otherSpeakers to {}
			set pandoraSource to null
			set spotifySource to null

			set allSpeakerOptions to get every speaker
			-- this doesn't work...but looping does
			-- set foo to get speaker whose name is "Feiler Blue HomePod Mini"
			repeat with a from 1 to length of allSpeakerOptions
				set speakerOption to item a of allSpeakerOptions
				
				if name of speakerOption is speakerName then
					set targetSpeaker to speakerOption
				else
					set end of otherSpeakers to speakerOption
				end if
				-- log "looping on speaker: " & (name of speakerOption)
			end repeat

			-- activate/toggle/etc. or update volume of the speaker
			if targetSpeaker is not null then
				if volumeCmd is not null then
					set currentVolume to volume of targetSpeaker
					if volumeCmd is "up" then
						set targetSpeaker's volume to (currentVolume + .06)
					else
						set targetSpeaker's volume to (currentVolume - .06)
					end if
				end if

				set turnedOn to false
				if activationCmd is not null then
					if activationCmd equals "on" then
						if (connected of targetSpeaker) is not true then
							connect to targetSpeaker
							set turnedOn to true
						end if
					else if activationCmd equals "off" then
						if (connected of targetSpeaker) is true then
							disconnect from targetSpeaker
						end if
					else if activationCmd equals "toggle" then
						-- special case; switching audio sources means we probably want to stay on
						if name of current audio source is not sourceName then
							-- log "switching source from '" & (name of current audio source) & "' -> '" & sourceName & "'; toggle actually on!"

							if (connected of targetSpeaker) is false then
								connect to targetSpeaker
								set turnedOn to true
							else
								set singleSpeakerLogic to false
							end if
						else
							if (connected of targetSpeaker) is true then
								disconnect from targetSpeaker
							else
								connect to targetSpeaker
								set turnedOn to true
							end if
						end if
					end if
				end if

				-- if this was set via -x
				-- if we turned on a single other speaker, turn off everything else
				-- if we turned it off, turn internal speaker back on.
				if singleSpeakerLogic is true then
					repeat with idx from 1 to length of otherSpeakers
						set otherSpeaker to item idx of otherSpeakers
						-- log "do something with " & (name of otherSpeaker) & "..."

						if turnedOn is true then
							if (connected of otherSpeaker) is true then
								disconnect from otherSpeaker
							end if
						else
							if (name of otherSpeaker) is "Computer" and (connected of otherSpeaker) is false then
								connect to otherSpeaker
							end if
						end if
					end repeat
				end if
			end if

		end tell
	end if

	if sourceName is not null
		tell application "Airfoil"
			set audioSource to null

			set allSourceOptions to get every application source
			repeat with a from 1 to length of allSourceOptions
				set sourceOption to item a of allSourceOptions
				
				if name of sourceOption equals sourceName then
					set audioSource to sourceOption
				end if

				--if name of sourceOption is "Pandora" then
					--set pandoraSource to sourceOption
				--else if name of sourceOption is "Spotify" then
					--set spotifySource to sourceOption
				--end if
			end repeat

			if audioSource is not null then
				set current audio source to audioSource
			end if
		end tell
	end if
	
end run

