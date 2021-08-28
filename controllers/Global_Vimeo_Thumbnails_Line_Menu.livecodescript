script "Global | Vimeo | Thumbnails | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Vimeo | Thumbnails | Line | Menu
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

private function _GetImageFile displayView
   put _GetImageUrl (displayView) into someLine
   put the display_Dictionary of displayView into displayDictionary
   --
   put displayDictionary [someLine]["file"] into imageFile
   if imageFile is empty then
      vimeo_DownloadThumbnail imageURL
      put the result into imageFile
      --
      put imageFile into displayDictionary [someLine]["file"]
      put imageURL into displayDictionary [someLine]["url"]
      set the display_Dictionary of displayView to displayDictionary
   end if
   --
   return imageFile
end _GetImageFile

function _GetImageUrl displayView
   put the selected_Index of displayView into imageURL
   return imageURL
end _GetImageUrl


--> Global | Vimeo | Thumbnails | Line | Menu
-
on menu_EditThumbnail displayView
   put _GetImageFile (displayView) into imageFile
   --
   launch imageFile with "/Applications/Pixelmator Pro.app"
end menu_EditThumbnail

on menu_ImportToPhotos displayView
   put the selected_Index of displayView into imageURL
   --
   set the itemdelimiter to slash
   set the linedelimiter to "?"
   put item -1 of line 1 of imageURL into shortFile
   put the tempname into folderName
   put folderName & slash & shortFile & ".jpeg" into imageFile
   create folder folderName
   --
   put url imageURL into url ("binfile:" & imageFile)
   --
   launch imageFile with "/System/Applications/Photos.app"
end menu_ImportToPhotos

on _
end _

on menu_RenameThumbnail displayView
   put the selected_Index of displayView into someLine
   put the selected_LineNumber of displayView into lineNum
   --
   put lcw_Ask ("Enter a new name for this link:", someLine) into newLine
   put the display_Dictionary of displayView into displayDictionary
   --
   put displayDictionary [someLine]["file"] into imageFile
   put displayDictionary [someLine]["url"] into imageURL
   --
   delete variable displayDictionary [someLine]
   --
   put imageFile into displayDictionary [newLine]["file"]
   put imageURL into displayDictionary [newLine]["url"]
   --
   set the display_Dictionary of displayView to displayDictionary
   --
   -- set the displayed_Line [lineNum] of displayView to newLine
   menu_Refresh displayView
   set the selected_Line of displayView to newLine
end menu_RenameThumbnail
   
on menu_RevealThumbnail displayView
   put _GetImageFile (displayView) into imageFile
   --
   finder_Reveal imageFile
end menu_RevealThumbnail

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

on menu_CheckType displayView
   put _GetImageUrl (displayView) into imageURL
   --
   put url imageURL into someImage
   put image_DetectType (someImage)
end menu_CheckType


--> Deps
-
