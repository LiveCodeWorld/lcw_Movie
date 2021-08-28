script "lib_DisplayVLC"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DisplayVLC
type: library
version: 0.1

/*Some help*/


--> Working on
-
function vlc_GetSecret
   put secret_Get ("vlc") into secretName
   return secretName
end vlc_GetSecret

command vlc_SetSecret secretName
   secret_Set "vlc", secretName
end vlc_SetSecret


--> Display | VLC
-
on mDoubleUp_VLCMarks displayView, someLine
   put the selected_Path of displayView into sPath
   put item 1 of sPath into sTime
   --
   vlc_Seek sTime
end mDoubleUp_VLCMarks

command display_VlcMarks modelName
   put vlc_GetModel (modelName) into mData
   display_Data mData, modelName, "VLC"
   put the result into dView
   set the tool_Menus of dView to "VLC | Marks"
end display_VlcMarks

command display_VlcStatus
   put vlc_FetchStatusArray() into sData
   display_Data sData, "Status Array", "VLC"
end display_VlcStatus



--> Deps
-
