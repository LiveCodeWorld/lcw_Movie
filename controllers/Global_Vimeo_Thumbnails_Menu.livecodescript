script "Global | Vimeo | Thumbnails | Menu"

--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Vimeo | Thumbnails | Menu
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

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

getprop quality_Param [displayView]
   put the thumb_Quality of displayView into qNum
   return qNum
end quality_Param

getprop quality_Params [mTarget]
   return "1,2,3,4,5,6"
end quality_Params


--> Global | Vimeo | Thumbnails | Menu
-
on menu_Quality displayView, qNum
   put the title_Text of displayView into vimeoID
   --
   display_VimeoThumbnails vimeoID, qNum
end menu_Quality

on menu_DownloadThumbnails displayView
   answer folder "Select or create a folder for the thubnails..."
   if it is empty then exit to top
   put it into thumbFolder
   --
   put the displayed_Index of displayView into thumbURLs
   set the itemdelimiter to slash
   put the display_Dictionary of displayView into displayDictionary
   --
   repeat for each line thumbURL in thumbURLs
      display_Spin thumbURL, displayView
      --
      vimeo_DownloadThumbnail thumbURL, thumbFolder
      put the result into thumbFile
      put item -1 of thumbFile into shortFile
      --
      put thumbFile into displayDictionary [shortFile]["file"]
      put thumbURL into displayDictionary [shortFile]["url"]
      --
      set the displayed_Line of displayView to shortFile
   end repeat
   --
   set the display_Dictionary of displayView to displayDictionary
end menu_DownloadThumbnails

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Refresh displayView
   put the display_Dictionary of displayView into displayDictionary
   --
   if displayDictionary is an array then
      put the keys of displayDictionary into someLines
      sort someLines
      set the displayed_Index of displayView to someLines
   else
      put the title_Text of displayView into vimeoID
      put the thumb_Quality of displayView into qNum
      display_VimeoThumbnails vimeoID, qNum
   end if
end menu_Refresh

on menu_ExportJson displayView
   put the display_Dictionary of displayView into displayDictionary
   --
   put displayDictionary into jsonData ["displayDictionary"]
   put the title_Text of sadf into jsonData ["title"]
   put the stack_Label of sadf into jsonData ["label"]
   --
   put json_FromArray (jsonData) into someJSON
   
   display_Data displayDictionary
end menu_ExportJson


--> Deps
-
