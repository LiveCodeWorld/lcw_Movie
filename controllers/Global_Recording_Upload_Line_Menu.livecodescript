script "Global | Recording | Upload | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Recording | Upload | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Working on
-
command _AnswerResult theResult
   if theResult is empty then
      set the recording_Path of cameraView to empty
      answer "Uploaded asset!"
   else
      put the result
      answer "Failed to upload file :("
   end if
end _AnswerResult


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

getprop menu_CheckTarget [mTarget]
  return true
end menu_CheckTarget

getprop checked_TestChecked
   return true
end checked_TestChecked


--> Global | Recording | Upload | Line | Menu
-
on menu_UploadVideo displayView
   put the selected_Index of displayView into domainName
   put the title_Text of displayView into shortFile
   --
   put camera_LocalRecordingPath (shortFile, true) into localRecordingFile
   --
   atopia_UploadRecording localRecordingFile
   --
   _AnswerResult the result
end menu_UploadVideo

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
