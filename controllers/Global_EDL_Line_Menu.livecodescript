script "Global | EDL | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | EDL | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

getprop test_Param [mTarget]
  return "b"
end test_Param

getprop test_Params [mTarget]
   return "a,b,c"
end test_Params


--> Global | EDL | Line | Menu
-
on menu_Seek indexView, seekWhere
   put the long id of grp 1 of stack "View|Movie" into mPlayer
   put the selected_Line of indexView into someLine
   edl_DeconstructLine someLine, editNum, realName, trackType, transitionType, sourceInPoint, sourceOutPoint, recorderInPoint, recorderOutPoint   
   
   switch seekWhere
      case "Start"
         put edl_ConvertToMovieSeconds (sourceInPoint) into mSeconds
         break
      case "End"
         put edl_ConvertToMovieSeconds (sourceOutPoint) into mSeconds
         break
      case "-"
      case "Frame before start"
         put edl_ConvertToMovieSeconds (sourceInPoint, -1) into mSeconds
         break
      case "Frame before end"
         put edl_ConvertToMovieSeconds (sourceOutPoint, -1) into mSeconds
         break
   end switch
   --
   set the movie_Seconds of mPlayer to mSeconds         
end menu_Seek

on menu_ExportClip indexView, cutFast
   put the long id of grp 1 of stack "View|Movie" into mPlayer
   --   
   _SelectedClipSeconds indexView, inSeconds, outSeconds
   put the movie_File of mPlayer into someVideoFile
   edl_ExportClip someVideoFile, inSeconds, outSeconds, "ask"
   put the result into exportedVideoPath
   -- put exportedVideoPath
end menu_ExportClip

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
private command _SelectedClipSeconds indexView, @inSeconds, @outSeconds
   put the selected_Line of indexView into someLine
   edl_DeconstructLine someLine, editNum, realName, trackType, transitionType, sourceInPoint, sourceOutPoint, recorderInPoint, recorderOutPoint   
   --
   put edl_ConvertToMovieSeconds (sourceInPoint) into inSeconds
   
   -- take one frame off out point
   put edl_ConvertToMovieSeconds (sourceOutPoint, -1) into outSeconds
end _SelectedClipSeconds
