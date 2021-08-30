script "Global | Camera | Menu"
--> MetaData
-
license: GPLv3
name: Global | Camera | Menu
type: controller
version: 0.2


--> Menu | Init
-
local LocalArray

getprop menu_Target [tObject]
   put the camera_View of tObject into cameraView
   if exists (cameraView) then
      put the camera_DeviceNames of cameraView into deviceNames
      put deviceNames into LocalArray ["deviceNames"]
      return cameraView
   end if
   
   put the display_View of tObject into dView
   if exists (dView) is false then return dView
   
   put the displayed_Object of dView into cameraView
   if exists (cameraView) then return cameraView
   
   return tObject
end menu_Target

getprop stackColour_Params
   return "default,-,black,white,red,yellow,green,-,choose"
end stackColour_Params

getprop camera_Param [cameraView]
   put the camera_DeviceName of cameraView into deviceName
   return deviceName
end camera_Param

getprop testClone_Params
   return LocalArray ["deviceNames"]
end testClone_Params
   
getprop camera_Params [cameraView]
   return LocalArray ["deviceNames"]
end camera_Params

getprop audio_Param [cameraView]
   put the audio_DeviceName of cameraView into deviceName
   return deviceName
end audio_Param

getprop audio_Params [cameraView]
   put the audio_DeviceNames of cameraView into deviceNames
   return deviceNames
end audio_Params

getprop shape_Param [cameraView]
   put the graphic_Shape of cameraView into gShape
   return gShape
end shape_Param

getprop shape_Params
   return "rectangle,roundrect,oval,-,hexagon,pentagon,triangle"
end shape_Params

getprop stackStyle_Param [cameraView]
   put the stack_Style of cameraView into sStyle
   return sStyle
end stackStyle_Param

getprop stackStyle_Params [cameraView]
   put the stack_Styles of cameraView into sStyles
   return sStyles
end stackStyle_Params


--> Global | Camera | Menu
-
on menu_Camera cameraView, deviceName
   set the camera_DeviceName of cameraView to deviceName
end menu_Camera

on menu_Audio cameraView, deviceName
   set the audio_DeviceName of cameraView to deviceName
end menu_Audio

on submenu_Record
   return "Global | Camera | Recording | Menu"
end submenu_Record

on submenu_Close
   return "Global | Camera | Close | Menu"
end submenu_Close

on _
end _

on menu_DisplayRecordings
   display_CameraRecordings
end menu_DisplayRecordings

on submenu_Frame
   return "Global | Frame | Menu"
end submenu_Frame

on menu_StackStyle cameraView, sStyle
   set the stack_Style of cameraView to sStyle
end menu_StackStyle

on menu_DeleteAllCameras cameraView
   dispatch "camera_DeleteAll" to cameraView
end menu_DeleteAllCameras

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _TestClone cameraView, deviceName
   put the camera_DeviceNames of cameraView
   --
   display_Camera deviceName
end _TestClone

on _Shape cameraView, gShape
   set the graphic_Shape of cameraView to gShape
end _Shape

on _EditBehavior cameraView
   put the behavior of cameraView into bObject
   edit the script of bObject
end _EditBehavior

on _PresentationMode cameraView
   put camera_ListStackNames() into sNames
   put camera_CheckAllFrameless (sNames) is false into toggleBoolean
   --
   repeat for each line sName in sNames
      if exists (control 1 of cd 1 of stack sName) is false then next repeat
      put the long id of control 1 of cd 1 of stack sName into cameraView
      --
      if toggleBoolean is true then
         set the stack_Frame of cameraView to "frameless"
      else
         set the stack_Frame of cameraView to "default"
      end if
      --
      set the systemwindow of stack sName to toggleBoolean
      set the shadow of stack sName to (not toggleBoolean)
   end repeat
end _PresentationMode

on _
end _

on _DisplayPageTitleArray
   display_PageTitleArray "vlog.mediagarden.org"
   put the result into displayView
   return displayView
end _DisplayPageTitleArray

on _
end _

on _StackColour cameraView, colourChoice
   put the stack_Name of cameraView into stackName
   --
   switch colourChoice
      case "default"
         set the backgroundcolor of stack stackName to empty
         break
      case "Choose"
         answer color with "black"
         if it is not empty then
            set the backgroundcolor of stack stackName to it
         end if
         break
      default
         set the backgroundcolor of stack stackName to colourChoice
   end switch
end _StackColour

on _
end _

on _OpenCamera cameraView
   put the stack_Name of cameraView into cameraName
   set the camera_Name of cameraView to cameraName
end _OpenCamera

on _Mask cameraView
   put the snap_Mask of cameraView into someBoolean
   set the snap_Mask ["blendDstIn"] of cameraView to (not someBoolean)
end _Mask

getprop checked_Mask [cameraView]
   put the snap_Mask of cameraView into someBoolean
   return someBoolean
end checked_Mask

