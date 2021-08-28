script "Global | Camera | Recording | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Camera | Recording | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-

--> Global | Camera | Recording | Line | Menu
-
on menu_RsyncPush displayView
   put the selected_Line of displayView into shortFile
   put camera_LocalRecordingPath (shortFile, true) into localFile
   --
   atopia_StoreAssetFile localFile, "david.obeya.xyz"
   put the result
end menu_RsyncPush

on _
end _

on menu_DeleteLocalRecording displayView
   put the selected_Line of displayView into shortFile
   put camera_LocalRecordingPath (shortFile, true) into mFilePath
   --
   lcw_Answer "Are you sure you want to delete the local recording '[[shortFile]]'?", displayView, shortFile
   --
   revDeleteFile mFilePath
   -- delete file mFilePath
   --
   put camera_ListLocalRecordings() into recordingFiles
   set the displayed_Index of displayView to recordingFiles
end menu_DeleteLocalRecording

on menu_RevealRecording displayView
   -- camera_RevealRecording cameraView
   put the selected_Line of displayView into shortFile
   put camera_LocalRecordingPath (shortFile, true) into mFilePath
   --
   finder_Reveal mFilePath
end menu_RevealRecording

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_TestRsync displayView
   put the selected_Line of displayView into shortFile
   put camera_LocalRecordingPath (shortFile, true) into localFile
   put "david.obeya.xyz" into wikiDomain
   --
   put atopia_WikiAssetFile (wikiDomain, shortFile) into fullPath
   atopia_CreateAssetFolder wikiDomain
   put rsync_ConstructFolderPushShell (localFile, fullPath, "root", "fedwiki.org") into someShell
   --
   -- atopia_StoreAssetFile mFilePath, "obeya.xyz"
   terminal_PasteInNewTab someShell
   put someShell
end menu_TestRsync

function rsync_ConstructFolderPushShell localFile, fullPath, sshUser, serverDomain
   put "rsync -aP" into someShell
   put space & kwote (localFile, "'") after someShell
   --
   put sshUser & "@" after remoteBit
   put serverDomain & ":" after remoteBit
   --
   -- put space & kwote (remoteBit, "'") after someShell -- does not work
   shell_BashParamEscape fullPath
   put kwote (fullPath, "'") after remoteBit
   put space & remoteBit after someShell
   return someShell
end rsync_ConstructFolderPushShell

on _
end _

on menu_RecordingMetadata displayView
   put the selected_Line of displayView into shortFile
   put camera_LocalRecordingPath (shortFile, true) into mFilePath
   --
   put spotlight_ListMovieInfo (mFilePath)
end menu_RecordingMetadata

on _
end _

-- on menu_UploadRecording displayView
   put the selected_Line of displayView into shortFile
   put camera_LocalRecordingPath (shortFile, true) into mFilePath
   --
   cameraView_AskUploadRecording mFilePath, cameraView
end menu_UploadRecording



--> Deps
-
