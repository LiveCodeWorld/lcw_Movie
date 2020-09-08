script "behavior_ViewCamera"
--> MetaData
-
license: GPLv3
name: behavior_ViewCamera
type: behavior
version: 0.1

/*
cameraControlDo cameraName, "takePicture"
put the result -- into url ("file:" & specialFolderPath("documents") & "/snapshot.jpg")
*/

--> Variables
-
local LocalArray

--> Working on
-

--> Events
-
on mouseDown pButtonNum
   switch pButtonNum
      case 3
         put empty into LocalArray ["mOffset"]
         menu_PopUp "Global | Camera | Menu"
         break
      default
         put the loc of me into mOffset
         get the mouseLoc
         subtract item 1 of it from item 1 of mOffset
         subtract item 2 of it from item 2 of mOffset
         put mOffset into LocalArray ["mOffset"]
   end switch
end mouseDown

on mouseMove
   if the mouse is not "down" then pass mouseMove
   
   put the stack_Name of me into stackName
   put LocalArray ["mOffset"] into mOffset
   if mOffset is empty then pass mouseMove
   
   -- put the globalloc of the loc of me & CR & the loc of stack stackName & CR & mOffset
   --
   put the globalloc of the mouseloc into newLoc
   --
   add item 1 of mOffset to item 1 of newLoc
   add item 2 of mOffset to item 2 of newLoc
   --
   set the loc of stack stackName to newLoc
end mouseMove

on resizeControl   
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl


--> Events | Custom
-
function png_IsTransparent pImageFile
   if not (there is a file pImageFile) then return "ERROR: Invalid file path!"
   set the filename of the templateImage to pImageFile
   put numtochar(0) into tZero
   return (tZero is in the alphaData of the templateImage) OR (tZero is in the maskData of the templateImage)
end png_IsTransparent

getprop snap_Mask
   put the graphic_Object of me into graphicObject
   put the short name of the defaultstack into stackName
   --
   get the windowshape of stack stackName
   put it is not 0 into someBoolean
   --
   return someBoolean
end snap_Mask

setprop snap_Mask [someInk] someBoolean
   put the graphic_Object of me into graphicObject
   --
   if someBoolean is true then
      if someInk is empty then
         -- set the ink of me to "blendSrc"
         export snapshot from graphicObject with effects to img "mask" of me as PNG
      else
         -- set the ink of graphicObject to "blendDstIn"
         -- set the ink of me to "blendSrcOver"
         export snapshot from me with effects to img "mask" of me as PNG
      end if
      put the short id of _ImageObject() into imageID
   else
      put 0 into imageID
   end if
   --
   put the short name of the defaultstack into stackName
   set the windowshape of stack stackName to imageID
end snap_Mask

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   put the graphic_Object of me into graphicObject
   --
   put the margins of me into someMargin
   margin_Normalize someMargin, leftM, topM, rightM, bottomM
   rect_SubtractMargins pRect, someMargin
   --
   put the camera_Name of me into cameraName
   if cameraName is not empty then
      set the camera_Rect of me to pRect
   end if
   --
   set the rect of graphicObject to pRect
   set the rect of _ImageObject() to pRect
   --
   unlock screen
end LayoutControl

function _ImageObject
   return the long id of image 1 of me
end _ImageObject

on refreshDisplay
   put the rect of me into viewRect
   LayoutControl viewRect
end refreshDisplay


--> Camera | Props
-
getprop camera_Name
   return LocalArray ["camera_Name"]
end camera_Name

setprop camera_Name [deviceName] cameraName
   if cameraName is empty then
      put LocalArray ["camera_Name"] into oldCameraName
      cameraControlDelete oldCameraName
      delete variable LocalArray
      return empty
   end if
   
   put the long id of the target into tObject 
   put the rect of tObject into someRect
   --
   put cameraName into LocalArray ["camera_Name"]
   --
   put cameraControls() into cameraNames
   if cameraName is not among the lines of cameraNames then
      cameraControlCreate cameraName
      put camera_ConstructDeviceArray (cameraName) into deviceArray
      put deviceArray into LocalArray ["deviceArray"]
   end if
   if deviceName is not empty then
      set the camera_DeviceName of me to deviceName
   end if
   --
   cameraControlSet cameraName, "rect", someRect
   cameraControlSet cameraName, "visible", true
   --
   return deviceArray
end camera_Name

getprop camera_Rect
   put the camera_Name of me into cameraName
   if cameraName is empty then return empty
   
   put cameraControlGet (cameraName, "rect") into someRect
   return someRect
end camera_Rect

setprop camera_Rect someRect
   put the camera_Name of me into cameraName
   if cameraName is empty then return empty
   
   cameraControlSet cameraName, "rect", someRect
   return the result
end camera_Rect

getprop camera_DeviceName
   put the camera_DeviceID of me into deviceID
   --
   put LocalArray ["deviceArray"] into deviceArray
   put deviceArray ["id"][deviceID] into deviceName
   return deviceName
end camera_DeviceName

setprop camera_DeviceName deviceName
   put deviceName into LocalArray ["camera_DeviceName"]
   put LocalArray ["deviceArray"] into deviceArray
   --
   put camera_GetDeviceID (deviceName, deviceArray) into deviceID
   set the camera_DeviceID of me to deviceID
   return deviceID
end camera_DeviceName

getprop camera_DeviceNames
   put the camera_Name of me into cameraName
   put camera_ListDeviceNames (cameraName) into deviceNames
   return deviceNames
end camera_DeviceNames

getprop camera_DeviceID
   put the camera_Name of me into cameraName
   put cameraControlGet (cameraName, "videoDevice") into deviceID
   return deviceID
end camera_DeviceID

setprop camera_DeviceID deviceID
   put the camera_Name of me into cameraName
   cameraControlSet cameraName, "videoDevice", deviceID
   return deviceID
end camera_DeviceID

getprop camera_DeviceNames
   put the camera_Name of me into cameraName
   put camera_ListDeviceNames (cameraName) into deviceNames
   return deviceNames
end camera_DeviceNames
   
function camera_GetDeviceID deviceName, deviceArray
   put deviceArray ["name"][deviceName] into deviceID
   return deviceID
end camera_GetDeviceID


--> Camera | Audio
-
getprop audio_DeviceName
   put the camera_Name of me into cameraName
   if cameraName is empty then return empty
   
   put cameraControlGet (cameraName, "audioDevice") into audioDevice
   return audioDevice
end audio_DeviceName

getprop audio_DeviceNames
   put the camera_Name of me into cameraName
   put audio_ListDeviceNames (cameraName) into deviceNames
   return deviceNames
end audio_DeviceNames

function audio_ListDeviceNames cameraName
   put audio_ConstructDeviceArray (cameraName) into deviceArray
   put deviceArray into LocalArray ["deviceArray"]
   --
   put deviceArray ["name"] into nameArray
   put keys (nameArray) into deviceNames
   sort deviceNames
   return deviceNames
end audio_ListDeviceNames

function audio_ConstructDeviceArray cameraName
   put cameraControlGet (cameraName, "audioDevices") into audioDeviceTable
   put _ArrayFromTable (audioDeviceTable) into deviceArray
   return deviceArray
end audio_ConstructDeviceArray


--> Camera
-
function camera_ListDeviceNames cameraName
   /*
   0x8020000005ac8514,FaceTime HD Camera (Built-in)
   EpocCamDevice:0,EpocCam
   0x2111000046d0826,HD Webcam C525 #4
   */
   
   put camera_ConstructDeviceArray (cameraName) into deviceArray
   put deviceArray into LocalArray ["deviceArray"]
   --
   put deviceArray ["name"] into nameArray
   put keys (nameArray) into deviceNames
   sort deviceNames
   return deviceNames
end camera_ListDeviceNames

command camera_DeleteAll pCameraNames
   if pCameraNames is empty then
      put cameraControls() into pCameraNames
   end if
   repeat for each line cameraName in pCameraNames
      cameraControlDelete cameraName
   end repeat
   delete variable LocalArray
end camera_DeleteAll

function camera_ConstructDeviceArray cameraName
   put cameraControlGet (cameraName, "videoDevices") into videoDeviceTable
   put _ArrayFromTable (videoDeviceTable) into deviceArray
   return deviceArray
end camera_ConstructDeviceArray

private function _ArrayFromTable videoDeviceTable
   put videoDeviceTable into idArray
   split idArray by CR and comma
   put idArray into deviceArray ["id"]
   
   repeat for each line someLine in videoDeviceTable
      put item 1 of someLine into videoDeviceID
      put item 2 of someLine into videoDeviceName
      put videoDeviceID into deviceArray ["name"][videoDeviceName]
   end repeat
   return deviceArray
end _ArrayFromTable


--> Objects
-
getprop graphic_Object
   return the long id of grc 1 of me
end graphic_Object

getprop view_Object
   return the long id of me
end view_Object
