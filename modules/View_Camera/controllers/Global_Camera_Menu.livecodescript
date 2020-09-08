script "Global_Camera_Menu"
--> MetaData
-
license: GPLv3
name: Global_Camera_Menu
type: controller
version: 0.1


--> Menu | Props
-
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

getprop disabled_Camera [cameraView]
   put the camera_Name of cameraView is not empty into isVisible
   return isVisible is false
end disabled_Camera

getprop disabled_TestCamera [cameraView]
   put the camera_Name of cameraView is not empty into isVisible
   return isVisible is true
end disabled_TestCamera

getprop disabled_DeleteCamera [cameraView]
   put the camera_Name of cameraView is not empty into isVisible
   return isVisible is false
end disabled_DeleteCamera

getprop setMask_Param [cameraView]
   put the snap_Mask of cameraView into someBoolean
   return someBoolean
end setMask_Param

getprop setMask_Params
   return "true,false"
end setMask_Params


--> Global | Camera | Menu
-
on menu_SetMask cameraView, someBoolean
   -- set the snap_Mask [""] of cameraView to someBoolean
   set the snap_Mask ["blendDstIn"] of cameraView to someBoolean
end menu_SetMask

on _
end _

on menu_TestCamera cameraView
   set the camera_Name of cameraView to the ticks
end menu_TestCamera

on menu_DeleteCamera cameraView
   set the camera_Name of cameraView to empty
end menu_DeleteCamera

on _
end _

on menu_Camera cameraView, deviceName
   set the camera_DeviceName of cameraView to deviceName
end menu_Camera

on _
end _

on menu_RecordVideo cameraView
   put the stack_Object of cameraView into stackObject
   
   get the effective filename of stackObject
   set the itemdelimiter to slash
   delete item -1 of it
   ask file "Save video as..." with it & "/untitled.mov" as sheet
   if it is empty then exit to top
   --
   put it into mFilePath
   put specialFolderPath("engine") & "/video.mp4" into defaultFilePath
   --
   put the camera_Name of cameraView into cameraName
   cameraControlDo cameraName, "startRecording", mFilePath
   put the result
end menu_RecordVideo

on menu_CloseRecording cameraView
   put the camera_Name of cameraView into cameraName
   --
   cameraControlDo cameraName, "stopRecording"
end menu_CloseRecording

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

on menu_Clone cameraView
   put the stack_Name of cameraView into stackName
   stack_Clone stackName
   put it into clonedStack
end menu_Clone
