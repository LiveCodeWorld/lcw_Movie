script "Global | Melt | Tree | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Melt | Tree | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

private function _PlayerObject
   put the long id of player 1 of stack "lcw_Movie" into playerObject
   return playerObject
end _PlayerObject


--> Global | Melt | Tree | Menu
-
on menu_AddClip dView
   put _PlayerObject() into mPlayer
   put the displayed_Array of dView into mltArray
   --
   put lcw_Ask ("Give a caption to this clip...", "Another clip") into shotcutCaption
   --
    --
   display_View mltArray, "melt_ConstructArray", "MLT"
   put the result into dView
end menu_AddClip

on _
end _

on menu_Export dView
   put the displayed_Array of dView into mltArray
   put melt_ConstructXML (mltArray) into mltXML
   --
   put _GetExportFolder() into meltFolder
   ask file "Save as..." with meltFolder as sheet
   put it into someFile
   if someFile is empty then exit to top
   --
   put mltXML into url ("file:" & someFile)
   --
   launch someFile with "/Applications/Shotcut.app"
end menu_Export

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_SetExportFolder mTarget
   put _GetExportFolder()
end menu_SetExportFolder


--> Deps
-
function _GetExportFolder
   put LocalArray ["exportFolder"] into exportFolder
   if there is a folder exportFolder then return exportFolder
   
   put "~/Movies/Melt/" into meltFolder
   folder_CreateNested meltFolder
   put meltFolder into LocalArray ["exportFolder"]
   return meltFolder
end _GetExportFolder
