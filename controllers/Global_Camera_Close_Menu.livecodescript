script "Global | Camera | Close | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Camera | Close | Menu
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


--> Global | Camera | Close | Menu
-
on menu_CloseCamera cameraView
   set the camera_Name of cameraView to empty
end menu_CloseCamera

on menu_CloseAllCameras
   camera_CloseAll
end menu_CloseAllCameras

on menu_ReopenCameras
   camera_ReOpenAll
end menu_ReopenCameras

on _
end _

on menu_CloseStack  cameraView
   set the camera_Name of cameraView to empty
   put the stack_Name of cameraView into stackName
   --
   put "delete stack" & kwote (stackName) into pigeon
   send pigeon to cameraView in 2 ticks
end menu_CloseStack
