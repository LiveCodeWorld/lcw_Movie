script "Global | iPlayer | Info | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | iPlayer | Info | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | iPlayer | Info | Menu
-
on menu_DownloadVideo dView
   put the displayed_Data of dView into iplayerMovieArray
   put iplayerMovieArray ["pID"] into pID
   --
   iplayer_DownloadVideo pID
end menu_DownloadVideo

private on _
end _

on menu_RevealVideo dView
   put the displayed_Data of dView into iplayerMovieArray
   put iplayerMovieArray ["filename"] into videoFile
   --
   if there is a file videoFile then
      put iplayerMovieArray ["filename"] into videoFile
      put iplayerMovieArray ["episodeTitle"] into episodeTitle
      --
      display_Video vFile, episodeTItle
   else
      menu_RevealDefaultOutputFolder
   end if
end menu_RevealVideo

on menu_ListDownloaded dView
   if the title_Text of dView = "Downloaded Videos" then
      put the video_Data of dView into videoData
      put videoData ["episodeTitle"] into episodeTitle
      set the displayed_Data [episodeTitle] of dView to videoData
   else
      put iplayer_GetDefaultOutupFolder() into oFolder
      put file_ListShort (oFolder, "*.mp4") into downloadedVideos
      --
      put the displayed_Data of dView into videoData
      set the video_Data of dView to videoData
      --
      set the displayed_Index ["Downloaded Videos"] of dView to downloadedVideos
   end if
end menu_ListDownloaded

getprop checked_ListDownloaded [dView]
   return the title_Text of dView = "Downloaded Videos"
end checked_ListDownloaded

on menu_RevealDefaultOutputFolder
   put iplayer_GetDefaultOutupFolder() into oFolder
   finder_Reveal oFolder
end menu_RevealDefaultOutputFolder

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | iPlayer | Info | Menu")
end submenu_Dev
