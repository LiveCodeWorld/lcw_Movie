script "lib_Iplayer"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Iplayer
type: library
version: 0.2

/*
This library wraps teh get_iplayer commandline tool.
*/


--> Working on
-
function iplayer_ListSeries pID
   put merge ("get_iplayer --pid=[[pID]] --pid-recursive-list") into someShell
   put shell (someShell) into shellResult
   --
   put lineOffset ("Episodes:", shellResult ) into lineNum
   delete line 1 to lineNum of shellResult
   set the itemdelimiter to ":"
   if item 1 of line -1 of shellResult = "INFO" then
      delete line -1 of shellResult
   end if
   --
   return word 1 to -1 of shellResult
end iplayer_ListSeries

function iplayer_EpisodesFromResult shellResult
   /*
   Episodes:
   Universe: Series 1 - The Sun: God Star, BBC Two, p09ybpb8
   INFO: 1 total programmes
   */
   
   _TrimResult shellResult, "Episodes:"
   return shellResult
end iplayer_EpisodesFromResult

private command _TrimSearchResult @searchResult
   _TrimResult searchResult, "Matches:"
   return the result
end _TrimSearchResult

private command _TrimResult @sResult, sectionTitle
   put lineOffset (sectionTitle, sResult) into lineNum
   if lineNum = 0 then
      put sResult into oResult
      put empty into sResult
      return oResult
   end if
   --
   delete line 1 to lineNum of sResult
   --
   repeat with lineNum = 1 to the number of lines of sResult
      if line lineNum of sResult is empty then
         put line 1 to (lineNum - 1) of sResult into sResult
      end if
   end repeat
   
   put line 1 to (lineNum + 1) of sResult into sResult
   return it
end _TrimResult


--> iPlayer
-
function iplayer_ListHistory
   put shell ("get_iplayer --history '.*'") into shellResult
   return hIndex
end iplayer_ListHistory

command iplayer_CleanMatch shellResult
   put lineoffset ("Matches:", shellResult) into lineNum
   put line (lineNum + 1) to -2 of shellResult into hIndex
   §
end iplayer_CleanMatch

function iplayer_Search sTerm
   put "get_iplayer" && kwote (sTerm) into someShell
   put shell (someShell) into searchResult
   _TrimSearchResult searchResult
   return searchResult
end iplayer_Search

command iplayer_DownloadSeries sID
   put merge ("get_iplayer --pid=[[sID]] --pid-recursive") into someShell
   put shell (someShell) into shellResult
   -- 
   put shellResult
end iplayer_DownloadSeries

command iplayer_DownloadVideo droppedURL
   /*
   get_iplayer --get "Top Gear" --type=tv --channel="BBC Two" --file-prefix="<nameshort><-senum><-episodeshort>" --output "/media/TV Shows 1/2 - TV Shows/Top Gear/Season 19"
   Storyville_-_01._United_Skates_m000kxl0_original.mp4
   "<name> - <episode> <pid> <version>"
   */
   
   set the cursor to watch
   put "get_iplayer --subtitles --force" && kwote (droppedURL) into someShell 
   put shell (someShell) into shellResult
   --
   put _ParseDownloadResult (shellResult) into resultArray
   put resultArray ["episodeTitle"] into episodeTitle
   return episodeTitle
end iplayer_DownloadVideo

command iplayer_DownloadSubtitles programID, pRaw
   if pRaw is true then
      put "get_iplayer --subtitles-only --subsraw --overwrite" into someShell
   else
      put "get_iplayer --subtitles-only" into someShell
   end if
   put space & "--pid=" & word 1 to -1 of programID after someShell 
   put shell (someShell) into shellResult
   return shellResult
end iplayer_DownloadSubtitles

command iplayer_Download programID, pWithSub
   set the cursor to watch
   put "get_iplayer" into someShell
   if pWithSub is true then
      put space & "--subtitles" after someShell
   end if
   put space & "--pid=" & word 1 to -1 of programID after someShell 
   put shell (someShell) into shellResult
   --
   return shellResult
end iplayer_Download

function iplayer_GetInfo programID
   -- m000kxl0
   put "get_iplayer --info --pid=" & programID into someShell
   put shell (someShell) into shellResult
   --
   put _ParseInfoResult (shellResult) into infoArray
   return infoArray
end iplayer_GetInfo

function iplayer_GetDefaultOutupFolder
   put iplayer_GetPrefsArray() into prefsArray
   put prefsArray ["output"] into outupFolder
   if outupFolder is empty then
      return the defaultfolder
   else
      return outupFolder
   end if
end iplayer_GetDefaultOutupFolder

function iplayer_GetPrefsArray
   put shell ("get_iplayer --prefs-show") into prefsResult
   delete line 1 of prefsResult
   set the itemdelimiter to "="
   repeat for each line sLine in prefsResult
      put word 1 to -1 of item 1 of sLine into sKey
      put word 1 to -1 of item 2 of sLine into sValue
      put sValue into prefsArray [sKey]
   end repeat
   return prefsArray
end iplayer_GetPrefsArray

command iplayer_SetDefaultOutupFolder sFolder
   -- Change your default output directory:
   
   -- "/home/user/get_iplayer"
   put "get_iplayer --prefs-add --output=" & kwote (sFolder) into someShell
   put shell (someShell) into shellResult
   return shellResult
end iplayer_SetDefaultOutupFolder

function iplayer_GetDownloadFolder
   -- /Users/fortyfoxes/Movies/iPlayer Downloads
   --put "~/Movies/iPlayer Downloads" into iplayerFolder
   put "~/Desktop/iPlayer Recordings" into iplayerFolder
   
   --vset the defaultfolder to iplayerFolder
   -- put the defaultfolder
   
   return iplayerFolder
end iplayer_GetDownloadFolder


--> Private
-
private function _ParseDownloadResult shellResult
   /*
   get_iplayer 3.25-homebrew, Copyright (C) 2008-2010 Phil Lewis
   This program comes with ABSOLUTELY NO WARRANTY; for details use --warranty.
   This is free software, and you are welcome to redistribute it under certain
   conditions; use --conditions for details.
   
   
   Episodes:
   Storyville - United Skates, BBC Four, m000kxl0
   INFO: 1 total programmes
   
   WARNING: A UK TV licence is required to access BBC iPlayer TV content legally
   INFO: Downloading tv: 'Storyville - 01. United Skates (m000kxl0) [original]'
   
   INFO: Downloaded: 3189.38 MB (01:20:42) @ 193.30 Mb/s (hvfhd1/bi) [audio+video]
   INFO: Converting to MP4
   INFO: Tagging MP4
   WARNING: You have programmes over 30 days old that should be deleted.
   WARNING: Find them with 'get_iplayer --history --before=720 ".*"'
   WARNING: or use the 'Recordings' tab in the Web PVR Manager.
   WARNING: Use 'get_iplayer --purge-files' to delete all programmes over 30 days old.
   WARNING: Use 'get_iplayer --prefs-add --no-purge' to suppress this warning.
   */
   -- put debug_GetCommentAbove() into shellResult
   
   put _ParseShellResult(shellResult) into resultArray
   --
   display_Data resultArray, "_ParseDownloadResult"
   return resultArray
end _ParseDownloadResult

private function _ParseInfoResult shellResult
   /*
   get_iplayer 3.25-homebrew, Copyright (C) 2008-2010 Phil Lewis
   This program comes with ABSOLUTELY NO WARRANTY; for details use --warranty.
   This is free software, and you are welcome to redistribute it under certain
   conditions; use --conditions for details.
   
   
   Episodes:
   Storyville - United Skates, BBC Four, m000kxl0
   INFO: 1 total programmes
   
   INFO: Processing tv: 'Storyville - 01. United Skates (m000kxl0)'
   
   brand:           Storyville
   categories:      Films,Factual
   category:        Factual
   channel:         BBC Four
   credits:         /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.credits.txt
   cuesheet:        /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.cue
   desc:            A community of thousands battles to save America's last roller rinks.
   desclong:        When America's last standing roller rinks are threatened with closure, a community of thousands battles in a racially charged environment to save an underground subculture - one that has remained undiscovered by the mainstream for generations, yet has given rise to some of the world's greatest musical talent.
   descmedium:      A Storyville documentary. When America's last standing roller rinks are threatened with closure, a community of thousands battles to save an underground subculture.
   descshort:       A community of thousands battles to save America's last roller rinks.
   dir:             /Users/fortyfoxes/Desktop/iPlayer Recordings
   dldate:          2020-08-01
   dltime:          00:26:58
   duration:        5160
   durations:       original: 5160
   episode:         01. United Skates
   episodenum:      1
   episodeshort:    United Skates
   expires:         in 1y 346 days 23 hours (2022-07-13T22:59:00+00:00)
   ext:             EXT
   filename:        /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.EXT
   filepart:        /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.partial.EXT
   fileprefix:      Storyville_-_01._United_Skates_m000kxl0_original
   firstbcast:      2020-07-14T22:00:00+01:00
   firstbcastdate:  2020-07-14
   firstbcastday:   14
   firstbcastmonth: 07
   firstbcastrel:   17 days 2 hours ago
   firstbcasttime:  22:00:00
   firstbcastyear:  2020
   longname:        Storyville
   modes:           original: hvfhd1,hvfhd2,hvfhd3,dvfhd1,dvfhd2,dvfhd3,hvfsd1,hvfsd2,hvfsd3,dvfsd1,dvfsd2,dvfsd3,hvfxsd1,hvfxsd2,hvfxsd3,hvfxsd4,hvfxsd5,hvfxsd6,dvfxsd1,dvfxsd2,dvfxsd3,hvfhigh1,hvfhigh2,hvfhigh3,dvfhigh1,dvfhigh2,dvfhigh3,hvfxhigh1,hvfxhigh2,hvfxhigh3,hvfxhigh4,hvfxhigh5,hvfxhigh6,hvfxhigh7,hvfxhigh8,hvfxhigh9,dvfxhigh1,dvfxhigh2,dvfxhigh3,hvflow1,hvflow2,hvflow3,hvflow4,hvflow5,hvflow6,dvflow1,dvflow2,dvflow3,subtitles1,subtitles2,subtitles3
   modesizes:       original: hvfhd1=3554MB,hvfhd2=3554MB,hvfhd3=3554MB,dvfhd1=3069MB,dvfhd2=3069MB,dvfhd3=3069MB,hvfsd1=2010MB,hvfsd2=2010MB,hvfsd3=2010MB,dvfsd1=1702MB,dvfsd2=1702MB,dvfsd3=1702MB,hvfxsd1=1162MB,hvfxsd2=1162MB,hvfxsd3=1162MB,hvfxsd4=1162MB,hvfxsd5=1162MB,hvfxsd6=1162MB,dvfxsd1=971MB,dvfxsd2=971MB,dvfxsd3=971MB,hvfhigh1=1161MB,hvfhigh2=1161MB,hvfhigh3=1161MB,dvfhigh1=950MB,dvfhigh2=950MB,dvfhigh3=950MB,hvfxhigh1=631MB,hvfxhigh2=653MB,hvfxhigh3=631MB,hvfxhigh4=653MB,hvfxhigh5=631MB,hvfxhigh6=653MB,hvfxhigh7=631MB,hvfxhigh8=631MB,hvfxhigh9=631MB,dvfxhigh1=501MB,dvfxhigh2=501MB,dvfxhigh3=501MB,hvflow1=364MB,hvflow2=364MB,hvflow3=364MB,hvflow4=364MB,hvflow5=364MB,hvflow6=364MB,dvflow1=264MB,dvflow2=264MB,dvflow3=264MB,subtitles2=169kB [estimated sizes only]
   name:            Storyville
   nameshort:       Storyville
   pid:             m000kxl0
   player:          https://www.bbc.co.uk/iplayer/episode/m000kxl0
   runtime:         86
   sebcast:         202007142200
   sebcastdate:     20200714
   sebcasttime:     2200
   senum:           s01e01
   senumx:          01x01
   series:          Series 1
   seriesnum:       1
   sesort:          s01e01
   sesortx:         01x01
   subsfile:        /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.srt
   subspart:        /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.partial.srt
   subsraw:         /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.ttml
   thumbfile:       /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.jpg
   thumbnail:       https://ichef.bbci.co.uk/images/ic/192x108/p08k67t3.jpg
   title:           Storyville: United Skates
   tracklist:       /Users/fortyfoxes/Desktop/iPlayer Recordings/Storyville_-_01._United_Skates_m000kxl0_original.tracks.txt
   type:            tv
   verpids:         original: m000kxkz
   version:         original
   versions:        original
   web:             https://www.bbc.co.uk/programmes/m000kxl0
   
   WARNING: You have programmes over 30 days old that should be deleted.
   WARNING: Find them with 'get_iplayer --history --before=720 ".*"'
   WARNING: or use the 'Recordings' tab in the Web PVR Manager.
   WARNING: Use 'get_iplayer --purge-files' to delete all programmes over 30 days old.
   WARNING: Use 'get_iplayer --prefs-add --no-purge' to suppress this warning.
   */
   -- put debug_GetCommentAbove() into shellResult
   
   put _ParseShellResult (shellResult) into resultArray
   --
   return resultArray
end _ParseInfoResult

private function _ParseShellResult shellResult
   _StripShellHead shellResult
   if the result is false then return empty
   --
   _StripShellTail shellResult
   _StripEpisodesSection shellResult
   put the result into episodeTitle
   put episodeTitle into resultArray ["episodeTitle"]
   --
   _StripInfoSection shellResult
   
   -- now let's turn into an array
   set the itemdelimiter to ":"
   repeat for each line someLine in shellResult
      put item 1 of someLine into sKey
      if sKey is empty then
         next repeat
      end if
      put word 1 to -1 of item 2 of someLine into resultArray [sKey]
   end repeat
   return resultArray
end _ParseShellResult

private command _StripInfoSection @shellResult
   -- delete first INFO: and WARNING: lines
   repeat 50 -- for safety
      get line 1 of shellResult
      switch
         case it begins with "INFO:"
         case it begins with "WARNING:"
         case word 1 to -1 of it is empty
            delete line 1 of shellResult
            break
         default
            -- not in info section
            return true
      end switch
   end repeat
   return false
end _StripInfoSection

private command _StripEpisodesSection @shellResult
   get line 1 of shellResult
   if it is not "Episodes:" then return empty
   
   put line 2 of shellResult into episodeTitle
   delete line 1 to 2 of shellResult
   --
   return episodeTitle
end _StripEpisodesSection

private command _StripShellHead @shellResult
   if word 1 of shellResult is not "get_iplayer" then return false
   
   -- delete first info lines
   delete line 1 of shellResult
   repeat 10 -- for safety
      if line 1 of shellResult is empty then
         exit repeat
      else
         delete line 1 of shellResult
      end if
   end repeat
   
   -- delete first empty lines
   delete line 1 of shellResult
   repeat 10 -- for safety
      if line 1 of shellResult is empty then
         delete line 1 of shellResult
      else
         return true
      end if
   end repeat
   return true
end _StripShellHead

private command _StripShellTail @shellResult
   -- delete last "WARNING: " lines
   repeat 30 -- for safety
      get line -1 of shellResult
      if it begins with "WARNING:" then
         delete line -1 of shellResult
      else
         return true
      end if
   end repeat
   return false
end _StripShellTail
