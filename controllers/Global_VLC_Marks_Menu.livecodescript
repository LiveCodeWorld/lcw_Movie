﻿script "Global | VLC | Marks | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | VLC | Marks | Menu
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



--> Global | VLC | Marks | Menu
-
on insert_Menu
   return "Global | VLC | Menu"
end insert_Menu

on _
end _

on menu_MenuHelp
   launch_MenuHelp
end menu_MenuHelp
