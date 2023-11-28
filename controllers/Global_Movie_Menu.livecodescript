script "Global | Movie | Menu"
--> MetaData
-
license: GPLv3
name: Global | Movie | Menu
type: controller
author: David Bovill
version: 0.4


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put the movie_Player of tObject into mPlayer
   if exists (mPlayer) is true then return mPlayer
   
   put the display_View of tObject into displayView
   if exists (displayView) is false then return empty
   
   put the displayed_Object of displayView into viewObject
   if exists (viewObject) is true then
      return viewObject
   else
      put the long id of player 1 of stack "lcw_Movie" into mPlayer
   end if
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

getprop disabled_YouTubeInfo dView
   put display_FindCloned ("View|Browser", "Browser") into browserView
   if exists (browserView) is false then return true
   --
   put the browser_URL of browserView into someURL
   -- https://www.youtube.com/watch?v=AGNNBoCjIP8
   if someURL begins with "https://www.youtube.com/watch?v=" then
      return false
   else
      return true
   end if
end disabled_YouTubeInfo


--> Global | Movie | Menu
-
on submenu_Vlc
   return "Global | VLC | Menu"
end submenu_Vlc

on submenu_Iplayer
   return "Global | iPlayer | Menu"
end submenu_Iplayer

private on _
end _

on menu_YoutubeBrowser mPlayer
   display_Browser "https://youtube.com"
end menu_YoutubeBrowser

on menu_ListDownloadFormats mPlayer
   put lcw_Ask ("Enter a Youtube url...", "https://www.youtube.com/watch?v=AGNNBoCjIP8") into youtubeUrl
   --
   put youtube_FetchFormatArray (youtubeUrl) into FormatArray
   display_Data FormatArray
end menu_ListDownloadFormats

on menu_DownloadYoutube mPlayer
   put lcw_Ask ("Enter a Youtube url...", "https://www.youtube.com/watch?v=AGNNBoCjIP8") into youtubeUrl
   --
   put fedwiki_LocalAssetsFolder() into assetFolder
   answer folder "Choose a dowload folder" with assetFolder as sheet
   put it into assetFolder
   if assetFolder is empty then exit to top
   set the defaultFolder to assetFolder
   --
   youtube_DownloadVideo youTubeUrl, true, "h264"
   put the result into mFile
   --
   display_Video mFile
end menu_DownloadYoutube

private on __
end __

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
   put the result into shellResult
   --
   display_Video pExportFilePath
   --
   put exportedVideoPath & CR & shellResult
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

private on ___
end ___

on submenu_Vimeo
   return "Global | Vimeo | Menu"
end submenu_Vimeo

on menu_YouTubeInfo
   -- https://www.youtube.com/watch?v=AGNNBoCjIP8
   put display_FindCloned ("View|Browser", "Browser") into browserView
   put the browser_URL of browserView into someURL
   --
   set the itemdelimiter to "="
   put item -1 of someURL into videoID
   --
   display_YoutubeVideoData videoID
end menu_YouTubeInfo

on menu_DownloadDocs
   launch_YoutubeDownloadDocumentation
end menu_DownloadDocs

on submenu_Dev
   return menu_Create ("Global | Movie | Dev | Menu")
end submenu_Dev

