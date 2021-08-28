script "lib_Camera"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_Camera
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_CameraRecordings
   put camera_ListLocalRecordings() into recordingFiles
   --
   display_Data recordingFiles, "Local", "Recordings"
   put the result into displayView
   display_SetInteractions displayView, "Camera | Recording", "mDoubleUp_Recording"
   return displayView
end display_CameraRecordings


--> Camera | Close
-
command camera_RevealRecording cameraView
   put the camera_Name of cameraView into cameraName
   put cameraName & ".mov" into shortFile
   put camera_LocalRecordingPath (shortFile) into mFilePath
   --
   finder_Reveal mFilePath
end camera_RevealRecording

command camera_CloseAll
   put camera_ConstructStackNameArray() into cameraStackNameArray
   put cameraStackNameArray ["open"] into openCameraArray
   repeat for each key sName in openCameraArray
      put openCameraArray [sName]["cView"] into cView
      put openCameraArray [sName]["cName"] into cName
      --
      -- set the camera_Name of cView to empty
      set camera_Open of cView to false
   end repeat
end camera_CloseAll

command camera_ReOpenAll cameraView
   put camera_ConstructStackNameArray() into cameraStackNameArray
   put cameraStackNameArray ["open"] into openCameraArray
   repeat for each key sName in openCameraArray
      put openCameraArray [sName]["cView"] into cView
      put openCameraArray [sName]["cName"] into cName
      --
      set camera_Open of cView to true
   end repeat
end camera_ReOpenAll


--> Camera
-
function camera_CheckAllFrameless sNames
   repeat for each line sName in sNames
      if the decorations of stack sName is not empty then
         return false
      end if
   end repeat
   return true
end camera_CheckAllFrameless

function camera_ListStackNames pFilterLive
   put camera_ConstructStackNameArray() into cameraStackNameArray
   switch pFilterLive
      case "closed"
         put cameraStackNameArray ["closed"] into sNameArray
         break
      case "open"
         put cameraStackNameArray ["open"] into sNameArray
         break
      default
         put cameraStackNameArray ["closed"] into cNameArray
         put cameraStackNameArray ["open"] into sNameArray
         union sNameArray with cNameArray
   end switch
   put the keys of sNameArray into sNames
   sort sNames
   return sNames
end camera_ListStackNames

function camera_ConstructStackNameArray
   put the openstacks into sNames
   filter sNames with "View|Camera*"
   repeat for each line sName in sNames
      get the long id of control 1 of stack sName
      put revRuggedId (it) into cameraView
      --
      put the camera_Name of cameraView into cName
      if cName is empty then
         put cameraView into cameraStackNameArray ["closed"][sName]
      else
         put cameraView into cameraStackNameArray ["open"][sName]["cView"]
         put cName into cameraStackNameArray ["open"][sName]["cName"]
      end if
   end repeat
   return cameraStackNameArray
end camera_ConstructStackNameArray


--> Camera | Files
-
function camera_ListLocalRecordings
   put camera_GetRecordingFolder (false) into rFolder
   put folder_ListShortFiles (rFolder) into rFiles
   return rFiles
end camera_ListLocalRecordings

function camera_LocalRecordingPath shortFile, pCreate
   put camera_GetRecordingFolder (pCreate) into rFolder
   return rFolder & shortFile
end camera_LocalRecordingPath

function camera_GetRecordingFolder pCreate
   put pref_GetValue ("Camera Recording Folder") into rFolder
   if rFolder is empty then
      put the home folder & "/Movies/Recordings/" into rFolder
      if pCreate is true then
         folder_CreateNested rFolder
      end if
   end if
   text_AddTrailing rFolder, slash
   return rFolder
end camera_GetRecordingFolder

command camera_SetRecordingFolder pFolder
   if pFolder is empty then
      put "~/Movies/Recordings" into defaultPath
      answer folder "Choose a recording folder..." with defaultPath
      put it into pFolder
      if pFolder is empty then
         return empty
      end if
   end if
   pref_SetValue "Camera Recording Folder", pFolder
   return pFolder
end camera_SetRecordingFolder
