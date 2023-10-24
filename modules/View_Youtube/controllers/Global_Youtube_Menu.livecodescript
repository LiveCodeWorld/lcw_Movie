script "Global | Youtube | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Youtube | Menu
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
   return display_MenuTarget(tObject)
   -- return the display_View of tObject
end menu_Target


--> Global | Youtube | Menu
-
on menu_BrowseYoutube browserView
   display_Browser "https://youtube.com"
end menu_BrowseYoutube

on menu_DisplayMyLists
   display_YoutTubePlaylists
end menu_DisplayMyLists

private on _
end _

on menu_Authenticate
   youtube_Authenticate
   --
   put the result into authArray
   if the result is "Not authorized!" then
      answer error "Not authorized!"
   else
      put authArray ["access_token"] into accessToken
      youtube_SetAccessToken accessToken
      --
      display_YoutTubePlaylists
   end if
end menu_Authenticate

private command __
end __

on menu_YoutubeApi browserView
   display_Browser "https://developers.google.com/youtube/v3"
end menu_YoutubeApi

on menu_ApiReference browserView
   display_Browser "https://developers.google.com/youtube/v3/docs/?apix=true"
end menu_ApiReference

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | Youtube | Menu")
end submenu_Dev
