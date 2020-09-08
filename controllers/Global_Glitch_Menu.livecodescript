script "Global | Glitch | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Glitch | Menu
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

getprop menu_Target [cardObject]
   put the long id of player 1 of cardObject into playerObject
   return playerObject
end menu_Target


--> Global | Glitch | Menu
-
on menu_PlayNext playerObject
   put the duration of playerObject into lastIntervalNum
   
   -- The callbacks of a player is a list of callbacks, one per line. Each callback consists of an interval number, a comma, and a message name. 
   put lastIntervalNum,"nextVideo" into messageList
   --
   set the callbacks of playerObject to messageList
end menu_PlayNext

on _
end _

on submenu_Movie
   return "Global | Movie | Menu"
end submenu_Movie

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_RevealMovie playerObject
   put the filename of playerObject into mFile
   put mFile
   finder_Reveal mFile
end menu_RevealMovie


--> Deps
-
