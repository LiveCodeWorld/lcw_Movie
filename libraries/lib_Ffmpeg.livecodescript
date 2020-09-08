script "lib_Ffmpeg"
--> MetaData
-
license: GPLv3
name: lib_Ffmpeg
type: library
version: 0.1


--> Display
-
command display_Video mFile
   mplayer_Play mFile
end display_Video


--> Working on
-
function time_SecondsToHMS someSeconds
   put someSeconds div 3600 into someHours 
   put someSeconds mod 3600 into secondsLeft
   --
   put secondsLeft div 60 into someMinutes
   put secondsLeft mod 60 into secondsLeft
   --
   put trunc (secondsLeft) into someSeconds
   get 100 * (secondsLeft - someSeconds)
   put round (it) into someFraction
   --
   put the numberformat into oFormat
   set the numberformat to "##"
   --
   put someHours & ":" & someMinutes & ":" & someSeconds into hms
   --
   set the numberformat to oFormat
   --
   put "." & someFraction after hms
   --
   return hms
end time_SecondsToHMS

function time_HmsfToSeconds hmsf
   set the itemdelimiter to ":"
   put item 1 of hmsf into someHours
   put item 2 of hmsf into someMinutes
   put item 3 of hmsf into someSeconds
   put item 4 of hmsf into someFrames
   
   add someHours * 3600 to someSeconds
   add someMinutes * 60 to someSeconds
   add someFrames / 25 to someSeconds
   
   return someSeconds
end time_HmsfToSeconds

function time_SecondsToHMSF someSeconds, someFrames
   put the numberformat into oFormat
   set the numberformat to "##"
   
   put someSeconds div 3600 into someHours 
   put someSeconds mod 3600 into secondsLeft
   
   put secondsLeft div 60 into someMinutes
   put secondsLeft mod 60 into secondsLeft
   
   put trunc(secondsLeft) into someSeconds
   put secondsLeft - someSeconds into someFraction
   
   if someFrames is empty then put round(someFraction * 25) into someFrames
   add 0 to someFrames
   
   get someHours & ":" & someMinutes  & ":" & someSeconds  & ":" & someFrames
   set the numberformat to oFormat
   return it
end time_SecondsToHMSF


--> ffmpeg | edl
-
command edl_ExportClip someVideoFile, sSeconds, eSeconds, pExportFilePath
   if pExportFilePath = "ask" then
      set the itemdelimiter to slash
      put someVideoFile into pExportFilePath
      put item -1 of pExportFilePath into shortExportFile
      put lcw_Ask ("What would you like to call the exported clip?", shortExportFile) into shortExportFile
      put shortExportFile into item -1 of pExportFilePath
   end if
   
   ffmpeg_SplitVideo someVideoFile, sSeconds, eSeconds, pExportFilePath, cutFast
   put the result into exportedVideoPath
   
   display_Video exportedVideoPath
   -- set the filename of playerObject to exportedVideoPath
   return exportedVideoPath
end edl_ExportClip

function edl_ConvertToMovieSeconds hmsfTimeWithHourStart, pAddFrames, pFPS
   if pFPS is empty then put 30 into pFPS
   set the itemdelimiter to ":"
   put "00" into item 1 of hmsfTimeWithHourStart
   --
   put item -1 of hmsfTimeWithHourStart + pAddFrames into newFrames
   put newFrames into item -1 of hmsfTimeWithHourStart
   --
   put time_HmsfToSeconds (hmsfTimeWithHourStart, pFPS) into movieSeconds
   return movieSeconds
end edl_ConvertToMovieSeconds

function edl_ParseLines someEDL
   put line 1 of someEDL into titleLine
   put line 2 of someEDL into dropLine
   delete line 1 to 2 of someEDL
   repeat for each line someLine in someEDL
      if someLine is empty then next repeat
      
      edl_DeconstructLine someLine, editNum, realName, trackType, transitionType, sourceInPoint, sourceOutPoint, recorderInPoint, recorderOutPoint
   end repeat
   return edlArray
end edl_ParseLines

command edl_DeconstructLine someLine, @editNum, @realName, @trackType, @transitionType, @sourceInPoint, @sourceOutPoint, @recorderInPoint, @recorderOutPoint
   put word 1 of someLine into editNum
   put word 2 of someLine into realName
   put word 3 of someLine into trackType
   put word 4 of someLine into transitionType
   put word 5 of someLine into sourceInPoint
   put word 6 of someLine into sourceOutPoint
   put word 7 of someLine into recorderInPoint
   put word 8 of someLine into recorderOutPoint
end edl_DeconstructLine


--> ffmpeg
-
command ffmpeg_SplitVideo someVideoFile, sSeconds, eSeconds, pExportFileName, pMakeAccurate
   file_Deconstruct someVideoFile, someRoot, shortName, fileExtension
   if pExportFileName is empty then 
      put someRoot & "/" & shortName & "_trimmed." & fileExtension into pExportFileName
      put pExportFileName into pExportFilePath
   end if
   --
   put ffmpeg_ConstructSplitVideoShell (someVideoFile, sSeconds, eSeconds, pExportFileName, pMakeAccurate) into someShell
   put someShell
   --
   set the cursor to watch
   put shell (someShell) into shellResult
   return shellResult
end ffmpeg_SplitVideo

function ffmpeg_ConstructSplitVideoShell someVideoFile, sSeconds, eSeconds, exportFileName, pMakeAccurate
   shell_BashParamEscape someVideoFile
   shell_BashParamEscape exportFileName
   --
   put "ffmpeg" into someShell
   if pMakeAccurate is true then
      put space & "-i" && someVideoFile after someShell
      put space & "-ss" && sSeconds after someShell -- fastest if first
   else
      put space & "-ss" && sSeconds after someShell -- fastest if first
      put space & "-i" && someVideoFile after someShell
   end if
   --
   put eSeconds - sSeconds into dSeconds
   put space & "-t" && dSeconds after someShell
   -- put space & "-to" && eSeconds after someShell
   --
   put space & "-c copy" after someShell -- keeps codecs the same and avoids reencoding
   put space & exportFileName after someShell
   --
   return someShell
end ffmpeg_ConstructSplitVideoShell

command ffmpeg_TrimVideo someVideoFile, sTime, cDuration
   set the cursor to watch
   file_Deconstruct someVideoFile, someRoot, shortName, fileExtension
   put someRoot & "/" & shortName & "_trimmed." & fileExtension into exportFileName
   put exportFileName into exportedVideoPath
   
   shell_BashParamEscape someVideoFile
   shell_BashParamEscape exportFileName
   
   put "ffmpeg -i" && someVideoFile into someShell
   put space & "-ss" && sTime && "-t" && cDuration after someShell
   put space & "-c:a copy" after someShell -- keeps the audio codec the same
   put space & exportFileName after someShell
   
   put shell (someShell) into shellResult
   put line -1 of shellResult into fileBit
   if fileBit ends with "Overwrite ? [y/N] Not overwriting - exiting" then
      -- File '/Users/.../.mp4' already exists. Overwrite ? [y/N] Not overwriting - exiting
      return empty
   else
      return exportedVideoPath
   end if
end ffmpeg_TrimVideo


--> Mplayer
-
/*
http://automatist.org/wiki/CLVE/Examples
*/

command mplayer_Play mFile
   -- don't use this to play
   -- need to open insead
   -- use this as a template for non-gui
   shell_BashParamEscape mFile
   
   -- put "./mplayer" && mFile into someShell
   put "mplayer" && mFile into someShell
   put mplayer_RootPath() into someRoot
   put shell_ExecuteAtRoot(someShell, someRoot) into shellResult
   return shellResult
end mplayer_Play

function mplayer_RootPath
    put "/Library/Application Support/ffmpegX/" into someRoot
    -- shell_BashParamEscape someRoot
    return someRoot
end mplayer_RootPath


--> Deps
-
command shell_BashParamEscape @someParam
   put word 1 to -1 of someParam into someParam
   if text_IsQuoted(someParam) is false then
      repeat for each char someChar in " |()"
         replace someChar with ("\" & someChar) in someParam
      end repeat
   end if
end shell_BashParamEscape

command file_Deconstruct someFile, @someRoot, @shortName, @fileExtension
    -- was "deconstruct_File"
    -- should turn someRoot into someFolder and add "/" to end
    
    if someFile is empty then
        put the effective filename of this stack into someFile
    end if
    put someFile into someRoot
    put the itemdelimiter into originalDelim
     
    set the itemdelimiter to "/"
    put last item of someFile into shortName
    delete last item of someRoot
     
    if shortName contains "." then
        set the itemdelimiter to "."
        put last item of shortName into fileExtension
        delete last item of shortName
    else
        put empty into fileExtension
    end if
    set the itemdelimiter to originalDelim
end file_Deconstruct
