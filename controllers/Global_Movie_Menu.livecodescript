﻿script "Global | Movie | Menu"
--> MetaData
-
license: GPLv3
name: Global | Movie | Menu
type: controller
version: 0.3


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put the movie_Player of tObject into mPlayer
   if exists (mPlayer) is false then
      put the long id of player 1 of stack "lcw_Movie" into mPlayer
   end if
   return mPlayer
end menu_Target

on mDouble_Up indexView, someLine
   put the long id of grp 1 of stack "View|Movie" into mPlayer
   --
   edl_DeconstructLine someLine, editNum, realName, trackType, transitionType, sourceInPoint, sourceOutPoint, recorderInPoint, recorderOutPoint   
   switch transitionType
      case "C"
         -- cut
         set the itemdelimiter to ":"
         put "00" into item 1 of sourceInPoint
         put "00" into item 1 of sourceOutPoint
         --
         put time_HmsfToSeconds (sourceInPoint, 30) into inSeconds
         put time_HmsfToSeconds (sourceOutPoint, 30) into outSeconds
         --
         lock screen
         set the movie_Seconds of mPlayer to inSeconds
         set the clip_StartTime of mPlayer to inSeconds
         set the clip_EndTime of mPlayer to outSeconds
         unlock screen
         if the shiftKey is "Down" then
            set the movie_PlaySelection of mPlayer to true
            set the movie_Paused of mPlayer to false
         else
            set the movie_PlaySelection of mPlayer to false
         end if
         break
      default
         get sourceInPoint,sourceOutPoint,recorderInPoint,recorderOutPoint
         replace comma with CR in it
         put it
   end switch
end mDouble_Up

getprop hiliteSelection_Param [mView]
   put the movie_ShowSelection of mView into someBoolean
   return someBoolean
end hiliteSelection_Param

getprop hiliteSelection_Params [mView]
   return "true,false"
end hiliteSelection_Params

getprop showController_Param [mView]
   put the movie_ControllerShowing of mView into someBoolean
   return someBoolean
end showController_Param

getprop showController_Params [mView]
   return "true,false"
end showController_Params

getprop cut_Fasts
   return "true,false"
end cut_Fasts

command movie_Play mPlayer
   -- set the movie_Paused of mPlayer to false
   --
   put the stack_Name of mPlayer into stackName
   put the short id of mPlayer into sID
   --
   start player id sID of stack stackName
end movie_Play


--> Global | Movie | Menu
-
on menu_PlayMovie mPlayer
   -- movie_Play mPlayer
   set the movie_Paused of mPlayer to false
end menu_PlayMovie

on menu_Shotcut mPlayer
   put the filename of mPlayer into someFile
   --
   launch someFile with "/Applications/Shotcut.app"
   -- launch someFile with "/System/Applications/QuickTime Player.app"
end menu_Shotcut

on _
end _

on menu_ExportSelectedClip mPlayer, cutFast
   put the clip_StartTime [s] of mPlayer into sSeconds
   put the clip_EndTime [s] of mPlayer into eSeconds
   put the movie_File of mPlayer into someVideoFile
   --
   set the itemdelimiter to slash
   put someVideoFile into pExportFilePath
   put item -1 of pExportFilePath into shortExportFile
   put lcw_Ask ("What would you like to call the exported clip?", shortExportFile) into shortExportFile
   put shortExportFile into item -1 of pExportFilePath
   --
   edl_ExportClip someVideoFile, sSeconds, eSeconds, pExportFilePath
   put the result into exportedVideoPath
   --
   put exportedVideoPath
end menu_ExportSelectedClip

on menu_DisplayEditMarkers mPlayer
   -- put the filename of mPlayer into someFile
   --
   -- if someFile is empty or the shiftKey is "Down" then
   answer file "Select an EDL"
   put it into someFile
   if someFile is empty then exit to top
   put someFile into LocalArray ["someFile"]
   -- end if
   
   put url ("file:" & someFile) into someEDL
   replace (CR & CR) with CR in someEDL
   put line 1 of someEDL into titleLine
   put line 2 of someEDL into dropLine
   
   put word 1 to -1 of line 3 to -1 of someEDL into edlLines
   
   set the itemdelimiter to slash
   put item -1 of someFile into stackLabel
   display_Lines edlLines, "EDL", "mDouble_Up", stackLabel
   put the result into indexView
   set the line_Menu of indexView to "Global | EDL | Line | Menu"
end menu_DisplayEditMarkers

on _
end _

on menu_ShowController mPlayer, someBoolean
   set the movie_ControllerShowing of mPlayer to someBoolean 
end menu_ShowController

on menu_HiliteSelection mPlayer, someBoolean
   set the movie_ShowSelection of mPlayer to someBoolean
end menu_HiliteSelection

on _
end _

on submenu_Vimeo
   return "Global | Vimeo | Menu"
end submenu_Vimeo

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditBehavior mPlayer
   put the behavior of mPlayer into bObject
   edit the script of bObject
end menu_EditBehavior

on _
end _

on menu_SetCallBacks mPlayer
   put "90000,soundNotes" & CR after messageList
   put "27000,soundNotes" & CR after messageList
   put "36000,soundNotes" & CR after messageList
   put "180000,soundNotes" & CR after messageList
   put "4000000,soundNotes" & CR after messageList
   delete char -1 of messageList
   
   set the callbacks of mPlayer to messageList
   put the callbacks of mPlayer
   --
   set the currenttime of mPlayer to 0
   -- movie_Play mPlayer
   set the movie_Paused of mPlayer to false
end menu_SetCallBacks

on _
end _

on menu_TestMeltXml
   answer file "Select a melt file..."
   put it into someFile
   put url ("file:" & someFile) into someXML
   --
   put xml_ToArray (someXML, false, empty, true, true) into someArray
   --
   display_View someArray
   --
   put xml_FromArray (someArray)
end menu_TestMeltXml

on menu_TestConstructMelt mPlayer
   put the melt_Array of mPlayer into mltArray
   --
   display_View mltArray, "melt_ConstructArray", "MLT"
   put the result into dView
   --
   set the title_Menu of dView to "Global | Melt | Tree | Menu"
   set the line_Menu of dView to "Global | Melt | Tree | Line | Menu"
end menu_TestConstructMelt

on _
end _

on menu_DownloadYoutube mPlayer
   put lcw_Ask ("Enter a Youtube url...", "https://www.youtube.com/watch?v=AGNNBoCjIP8") into youtubeUrl
   youtube_DownloadVideo youtubeUrl
   put the result into videoFile
   --
   set the filename of mPlayer to videoFile
end menu_DownloadYoutube

on menu_MplayMovie mPlayer
   put the movie_Player of mPlayer into pObject
   put the movie_File of mPlayer into mFile
   mplayer_Play mFile
   -- put the result
end menu_MplayMovie

on menu_DisplayMovie mPlayer
   answer file "Select a movie file..." -- with type "MPEG-4 movie"
   put it into someFile
   
   put file_IsVideo (someFile)
   
   /*
   put "file -I" && kwote (someFile) into someShell
   put shell (someShell) into shellReply
   -- /Users/BabyBlue/Movies/Guerrilla.mp4: video/mp4; charset=binary
   set the itemdelimiter to ":"
   put word 1 of item 2 of shellReply ="video" into isVideo
   */
   
   put spotlight_GetFileKind (someFile) into fileKind
   -- MPEG-4 movie
   put fileKind & CR & CR & spotlight_GetFileInfo (someFile)
end menu_DisplayMovie



--> END

on insert_MoviePlayerMenu
   return "Global | Movie | Video | Menu"
end insert_MoviePlayerMenu

on _
end _

on submenu_Capture
   return "Global | Movie | Capture | Menu"
end submenu_Capture

on submenu_RecordMovie
   return "Global | Movie | Record | Menu"
end submenu_RecordMovie

on submenu_BookMarkMenu
   return "Global | Movie | Bookmarks | Menu", subMenu
end submenu_BookMarkMenu

on submenu_MovieCallMenu
   menu_DoSub "Global | Movie | Call | Menu"
end submenu_MovieCallMenu

on submenu_QuickTime
   return "Global | QuickTime | Menu"
end submenu_QuickTime

on submenu_MovieTools
   return "Movie | Tools | Menu"
end submenu_MovieTools

on submenu_MovieWindowMenu
   return "Global | Movie | Window | Menu"
end submenu_MovieWindowMenu
