script "Global | Camera | Recording | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Camera | Recording | Menu
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
   put camera_ListLocalRecordings() into recordingFiles
   put recordingFiles into LocalArray ["recordingFiles"]
   --
   put the camera_View of tObject into cameraView
   return cameraView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

command mDouble_UploadRecording
   put the params
end mDouble_UploadRecording

command cameraView_AskUploadRecording mFilePath, cameraView
   if there is not a file mFilePath then
      put "Error, file does not exits!" && mFilePath into someComment
      return someComment
   end if
   set the itemdelimiter to slash
   put item -1 of mFilePath into shortFile
   --
   put lcw_Ask ("Choose a title for a wiki page for this recording...", shortFile) into pTitle
   put lcw_Ask ("Describe this recording...", empty) into pDescription
   --
   atopia_UploadRecording mFilePath, pTitle, pDescription
   --
   put the result into wikiURL
   if theResult is empty then
      answer "Failed to upload file :("
   else
      launch url wikiURL
   end if
end cameraView_AskUploadRecording

command _AnswerResult theResult
   if theResult is empty then
      set the recording_Path of cameraView to empty
      answer "Uploaded asset!"
   else
      put the result
      answer "Failed to upload file :("
   end if
end _AnswerResult

getprop uploadRecording_Params
   return LocalArray ["recordingFiles"]
end uploadRecording_Params

getprop deleteLocalRecording_Params
   return LocalArray ["recordingFiles"]
end deleteLocalRecording_Params

getprop recordingMetadata_Params
   return LocalArray ["recordingFiles"]
end recordingMetadata_Params

getprop disabled_StartRecording [cameraView]
   if the shiftkey is "Down" then return false
   put the recording_Path of cameraView into mFilePath
   if mFilePath is empty then
      return false
   else
      return true
   end if
end disabled_StartRecording

getprop disabled_StopRecording [cameraView]
   put the recording_Path of cameraView into mFilePath
   if mFilePath is empty then
      return true
   else
      return false
   end if
end disabled_StopRecording


--> Global | Camera | Recording | Menu
-
on menu_StartRecording cameraView
   put the stack_Label of cameraView into sLabel
   if sLabel is empty then
      put the camera_Name of cameraView into cameraName
      put cameraName & ".mp4" into shortFile
   else
      put sLabel & ".mp4" into shortFile
   end if
   put lcw_Ask ("Choose a file name for this recording", shortFile, cameraView) into shortFile
   put camera_LocalRecordingPath (shortFile, true) into mFilePath
   --
   if there is a file mFilePath then
      put mFilePath
      lcw_AnswerWarning "File already exists. Please choose another file name", cameraView
   end if
   --
   cameraControlDo cameraName, "startRecording", mFilePath
   put the result into someResult
   --
   set the recording_Path of cameraView to mFilePath
end menu_StartRecording

on menu_StopRecording cameraView
   put the camera_Name of cameraView into cameraName
   --
   cameraControlDo cameraName, "stopRecording"
   put the result into doResult
   --
   put the recording_Path of cameraView into mFilePath
   --
   set the recording_Path of cameraView to empty
   cameraView_AskUploadRecording mFilePath, cameraView
   put the result into someError
   --
   if item 1 of someError is "error" then
      lcw_Answer someError, cameraView
   else
   end if
end menu_StopRecording

on _
end _

on submenu_Recordings
   return "Recordings | Menu"
end submenu_Recordings

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Recordings | Menu
-
on menu_RecordingMetadata cameraView, shortFile
   put camera_LocalRecordingPath (shortFile, true) into movieFile
   --
   put spotlight_ListMovieInfo (movieFile)
end menu_RecordingMetadata

on menu_DeleteLocalRecording cameraView, shortFile
   put the long id of control 1 of cd 1 of stack "View|Camera" into cameraView
   --
   put the camera_Name of cameraView into cameraName
   put camera_LocalRecordingPath (shortFile, true) into mFilePath
   --
   lcw_Answer "Are you sure you want to delete the local recording '[[shortFile]]'?", cameraView, shortFile
   --
   delete file mFilePath
end menu_DeleteLocalRecording

on menu_UploadRecording cameraView, shortFile
   put camera_LocalRecordingPath (shortFile, true) into mFilePath
   --
   cameraView_AskUploadRecording mFilePath, cameraView
end menu_UploadRecording

on menu_RevealRecording cameraView
   camera_RevealRecording cameraView
end menu_RevealRecording
