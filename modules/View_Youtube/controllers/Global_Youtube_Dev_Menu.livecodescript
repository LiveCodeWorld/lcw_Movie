script "Global | Youtube | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Youtube | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Youtube | Dev | Menu
-
on menu_SetClientId browserView
   put youtube_GetClientID() into clientID
   put lcw_Ask ("Set the new client id...", clientID) into clientID
   youtube_SetClientID clientID
end menu_SetClientId

on menu_SetClientSecret browserView
   put youtube_GetClientSecret() into clientSecret
   put lcw_Ask ("Set the new api key...", clientSecret) into clientSecret
   youtube_SetClientSecret clientSecret
end menu_SetClientSecret

on menu_SetApiKey browserView
   put youtube_GetApiKey() into apiKey
   put lcw_Ask ("Set the new api key...", apiKey) into apikey
   youtube_SetApiKey apiKey
end menu_SetApiKey
