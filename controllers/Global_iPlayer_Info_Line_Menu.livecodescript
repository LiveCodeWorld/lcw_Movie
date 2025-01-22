script "Global | iPlayer | Info | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | iPlayer | Info | Line | Menu
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

on mDoubleUp_iPlayerInfo dView, shortFile  
   if the optionKey is "Down" then breakpoint
   
   _DisplayVideo shortFile, dView
   --
   put the video_Data of dView into iplayerMovieArray
   put iplayerMovieArray ["pID"] into pID
end mDoubleUp_iPlayerInfo

private command _DisplayVideo shortFile, dView
   put iplayer_DownloadedFile (shortFile) into vFile
   --
   put the video_Data of dView into videoData
   put videoData ["episodeTItle"] into episodeTItle
   display_Video vFile, episodeTItle
   return the result
end _DisplayVideo


--> Global | iPlayer | Info | Line | Menu
-
on menu_IplayerInfoLine dView
   put the selected_Line of dView into shortFile
   --
   _DisplayVideo shortFile, dView
end menu_IplayerInfoLine

private on _
end _

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
   return menu_DevTitle ("Global | iPlayer | Info | Line | Menu")
end submenu_Dev
