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
   -- called once for each menu
   return the display_View of tObject
end menu_Target


--> Global | iPlayer | Menu
-
on menu_Download displayView
   put the displayed_ProgramID of displayView into sID
   --
   iplayer_DownloadSeries sID
end menu_Download

on _
end _

on submenu_Iplayer
   return "Global | iPlayer | Menu"
end submenu_Iplayer

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
