(* LyricScript.applescript
 
 AppleScripts used alternatively to set a lyric to a track 
 
 Add a build phase to executes this command:
 
 osacompile -d -o LyricScript.scpt LyricScript.applescript
 *)

on SetLyric(databaseID, newLyric)
	tell application "iTunes"
		set mainlibrary to library playlist 1
		--since databaseID is unique we can use first track
		tell (first track of mainlibrary whose database ID = databaseID)
			set lyrics to newLyric
		end tell
	end tell
end SetLyric