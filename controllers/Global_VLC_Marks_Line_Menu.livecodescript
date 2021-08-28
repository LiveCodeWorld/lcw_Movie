script "Global | VLC | Marks | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | VLC | Marks | Line | Menu
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


--> Global | VLC | Marks | Line | Menu
-
on menu_Test displayView
   put the selected_Path of displayView into sPath
   put item 1 of sPath into sTime
   --
   vlc_Seek sTime
   --
   get the top_Array of displayView
   put it ["position"]
end menu_Test

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _Experiment displayView
   put displayView
end _Experiment
