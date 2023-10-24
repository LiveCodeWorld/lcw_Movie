script "Global | iPlayer | Menu"
--> MetaData
-
copyright: David Bovill
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
   display_SearchIplayer
end menu_SearchIplayer

on menu_Download displayView
   put the displayed_ProgramID of displayView into sID
   --
   iplayer_DownloadSeries sID
end menu_Download

on _
end _

on submenu_Dev
   return menu_DevTitle("Global | iPlayer | Menu")
end submenu_Dev
