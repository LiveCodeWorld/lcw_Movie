script "Global | iPlayer | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | iPlayer | Menu
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
   return the display_View of tObject
end menu_Target

getprop disabled_Download [displayView]
   put the displayed_ProgramID of displayView into sID
   return sID is empty
end disabled_Download


--> Global | iPlayer | Menu
-
on menu_SearchIplayer
   put ask_Question ("What would uyou like to search for?", "Prime Minister's Questions", "Search BBC  iPlayer") into sTerm
   --
   put iplayer_Search (sTerm) into foundIndex
   --
   display_Data foundIndex, sTerm, "iPLayer"
end menu_SearchIplayer

on menu_Download displayView
   put the displayed_ProgramID of displayView into sID
   --
   iplayer_DownloadSeries sID
end menu_Download

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
