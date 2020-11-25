script "Global | Vimeo | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Vimeo | Menu
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


--> Global | Vimeo | Menu
-
on menu_DisplayBrowser
   display_View viewName, "Browser"
end menu_DisplayBrowser

on menu_UploadVideoToWiki
   answer file "Which video do you want to move?"
   put it into mFile
   if it is empty then exit to top
   --
   atopia_UploadAsset "conversation.wiki", mFile
   --
   if the result is empty then
      answer "Uploaded asset!"
   else
      put the result
      answer "Failed to upload file :("
   end if
end menu_UploadVideoToWiki

on menu_MoveVideoFile
   answer file "Which video do you want to move?"
   put it into mFile
   if it is empty then exit to top
   --
   set the itemdelimiter to slash
   put item -1 of mFile into shortFile
   --
   put camera_ConstructRecordingPath (shortFile, true) into newFile
   --
   rename file mFile to newFile
end menu_MoveVideoFile

on _
end _

on menu_DisplayMyVideos
   -- just the last 25
   put vimeo_ListUserVideos() into videoData
   put vimeo_ConstructTitleArray (videoData) into videoTitleArray
   --
   display_Data videoTitleArray, "My Recent Videos", "Vimeo"
   put the result into displayView
   --
   set the vimeo_Data of displayView to videoData
end menu_DisplayMyVideos

on menu_LaunchDocumentation
   vimeo_LaunchApiDocumentation
end menu_LaunchDocumentation

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment mTarget
   put mTarget
end menu_Experiment


--> Deps
-
