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

getprop stackColour_Params
   return "default,-,black,white,red,yellow,green,-,choose"
end stackColour_Params

getprop camera_Param [cameraView]
   put the camera_DeviceName of cameraView into deviceName
   return deviceName
end camera_Param

getprop camera_Params [cameraView]
   put the camera_DeviceNames of cameraView into deviceNames
   return deviceNames
end camera_Params

getprop audio_Param [cameraView]
   put the audio_DeviceName of cameraView into deviceName
   return deviceName
end audio_Param

getprop audio_Params [cameraView]
   put the audio_DeviceNames of cameraView into deviceNames
   return deviceNames
end audio_Params

getprop disabled_CloseCamera [cameraView]
   put the camera_Name of cameraView is not empty into isVisible
   return isVisible is false
end disabled_CloseCamera

getprop frame_Param [cameraView]
   put the stack_Frame of cameraView into stackFrame
   return stackFrame
end frame_Param

getprop frame_Params
   return "frameless,palette,toplevel"
end frame_Params

getprop shape_Param [cameraView]
   put the graphic_Shape of cameraView into gShape
   return gShape
end shape_Param

getprop shape_Params
   return "rectangle,roundrect,oval,-,hexagon,pentagon,triangle"
end shape_Params

getprop checked_PresentationMode
   put camera_ListStackNames() into sNames
   put camera_CheckAllFrameless (sNames) into someBoolean
   return someBoolean
end checked_PresentationMode

getprop checked_SystemWindow [cameraView]
   put the system_Window of cameraView into someBoolean
   return someBoolean
end checked_SystemWindow


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
   return "Camera | Close | Menu"
end submenu_Close

on _
end _

on menu_Clone cameraView
   put the stack_Label of cameraView into cameraName
   if cameraName is empty then
      put the stack_Name of cameraView into cameraName
   end if
   --
   put lcw_Ask ("Give the new camera a name...", cameraName) into newCameraName
   --
   put the stack_Name of cameraView into stackNameToClone
   stack_Clone stackNameToClone, newCameraName
   --
   put the result into clonedStack
end menu_Clone

on _
end _

on menu_Frame cameraView, fameStyle
   set the stack_Frame of cameraView to fameStyle
end menu_Frame

on menu_SystemWindow cameraView
   put the system_Window of cameraView into someBoolean
   set the system_Window of cameraView to (not someBoolean)
end menu_SystemWindow

on menu_Shape cameraView, gShape
   set the graphic_Shape of cameraView to gShape
end menu_Shape

on menu_EditLabel cameraView
   put the stack_Label of cameraView into oldLabel
   --
   put lcw_Ask ("Edit the lable of this camera view...", oldLabel) into newLabel
   --
   set the stack_Label of cameraView to newLabel
end menu_EditLabel

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Camera | Close | Menu
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


--> Dev | Menu
-
on menu_EditBehavior cameraView
   put the behavior of cameraView into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_PresentationMode cameraView
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
end menu_PresentationMode

on _
end _

on menu_DisplayPageTitleArray
   display_PageTitleArray "vlog.mediagarden.org"
   put the result into displayView
   return displayView
end menu_DisplayPageTitleArray

on _
end _

on menu_StackColour cameraView, colourChoice
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
end menu_StackColour

on _
end _

on menu_OpenCamera cameraView
   put the stack_Name of cameraView into cameraName
   set the camera_Name of cameraView to cameraName
end menu_OpenCamera

on menu_Mask cameraView
   put the snap_Mask of cameraView into someBoolean
   set the snap_Mask ["blendDstIn"] of cameraView to (not someBoolean)
end menu_Mask

on menu_DeleteAllCameras cameraView
   dispatch "camera_DeleteAll" to cameraView
end menu_DeleteAllCameras

getprop checked_Mask [cameraView]
   put the snap_Mask of cameraView into someBoolean
   return someBoolean
end checked_Mask
