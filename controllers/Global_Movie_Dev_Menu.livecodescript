script "Global | Movie | Dev | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Movie | Dev | Menu
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
   -- called once for each menu
   return the display_View of tObject
end menu_Target

getprop checked_ShowBrowser [movieView]
   put the show_Browser of movieView into isShowing
   return isShowing
end checked_ShowBrowser


--> Global | Movie | Dev | Menu
-
on menu_DisplaySeries
   display_IplayerSeries pID
end menu_DisplaySeries

on menu_PlayMovie mPlayer
   set the movie_Paused of mPlayer to false
end menu_PlayMovie

on menu_ShowBrowser movieView
   put the show_Browser of movieView is false into isNotShowing
   set the show_Browser of movieView to isNotShowing
end menu_ShowBrowser

on menu_ShowController mPlayer, someBoolean
   set the movie_ControllerShowing of mPlayer to someBoolean 
end menu_ShowController

on menu_HiliteSelection mPlayer, someBoolean
   set the movie_ShowSelection of mPlayer to someBoolean
end menu_HiliteSelection

on menu_Shotcut mPlayer
   put the filename of mPlayer into someFile
   --
   launch someFile with "/Applications/Shotcut.app"
   -- launch someFile with "/System/Applications/QuickTime Player.app"
end menu_Shotcut

on _
end _

on menu_TestVimeo movieView
   -- edit the script of stack lib_Vimeo
   put lcw_Ask ("Embed Vimeo video:", 229827899) into vimeoID
   --
   put vimeo_HtmlEmbed (vimeoID) into iframeHTML
   -- set the browser_Html of movieView to iframeHTML
   put html_GetIframeSrc (iframeHTML) into videoURL
   set the browser_URL of movieView to videoURL
end menu_TestVimeo

on menu_TestYoutube movieView
   --edit the script of stack lib_Youtube
   put lcw_Ask ("Embed Youtube video:", Qav6joFjKw0) into videoID
   --
   put youtube_HtmlEmbed (videoID) into iframeHTML
   -- set the browser_Html of movieView to iframeHTML
   put html_GetIframeSrc (iframeHTML) into videoURL
   put "https:" before videoURL
   set the browser_URL of movieView to videoURL
end menu_TestYoutube

on menu_TestHtml5Video movieView
   put "http://liquidlaw.org/assets/Legislative_Theatre_Animated_Presentation.mp4" into videoURL
   set the movie_File of movieView to videoURL
end menu_TestHtml5Video

on menu_Html5BrowserVideo movieView
   put "http://liquidlaw.org/assets/Legislative_Theatre_Animated_Presentation.mp4#t=01:08,02:08" into videoURL
   set the browser_URL of movieView to videoURL
end menu_Html5BrowserVideo

on menu_MplayMovie mPlayer
   put the movie_Player of mPlayer into pObject
   put the movie_File of mPlayer into mFile
   mplayer_Play mFile
   -- put the result
end menu_MplayMovie

on menu_DisplayMovie mPlayer
   answer file "Select a movie file..." -- with type "MPEG-4 movie"
   put it into someFile
   
   put file_IsVideo (someFile)
   
   /*
   put "file -I" && kwote (someFile) into someShell
   put shell (someShell) into shellReply
   -- /Users/BabyBlue/Movies/Guerrilla.mp4: video/mp4; charset=binary
   set the itemdelimiter to ":"
   put word 1 of item 2 of shellReply ="video" into isVideo
   */
   
   put spotlight_GetFileKind (someFile) into fileKind
   -- MPEG-4 movie
   put fileKind & CR & CR & spotlight_GetFileInfo (someFile)
end menu_DisplayMovie

on menu_EditBehavior mPlayer
   put the behavior of mPlayer into bObject
   edit the script of bObject
end menu_EditBehavior

on mmenu_EditMenuButton movieView
   put the menu_Button of movieView into mButton
   edit the script of mButton
end mmenu_EditMenuButton

on menu_SetCallBacks mPlayer
   put "90000,soundNotes" & CR after messageList
   put "27000,soundNotes" & CR after messageList
   put "36000,soundNotes" & CR after messageList
   put "180000,soundNotes" & CR after messageList
   put "4000000,soundNotes" & CR after messageList
   delete char -1 of messageList
   
   set the callbacks of mPlayer to messageList
   put the callbacks of mPlayer
   --
   set the currenttime of mPlayer to 0
   -- movie_Play mPlayer
   set the movie_Paused of mPlayer to false
end menu_SetCallBacks

on menu_TestMeltXml
   answer file "Select a melt file..."
   put it into someFile
   put url ("file:" & someFile) into someXML
   --
   put xml_ToArray (someXML, false, empty, true, true) into someArray
   --
   display_View someArray
   --
   put xml_FromArray (someArray)
end menu_TestMeltXml

on menu_TestConstructMelt mPlayer
   put the melt_Array of mPlayer into mltArray
   --
   display_View mltArray, "melt_ConstructArray", "MLT"
   put the result into dView
   --
   set the title_Menu of dView to "Global | Melt | Tree | Menu"
   set the line_Menu of dView to "Global | Melt | Tree | Line | Menu"
end menu_TestConstructMelt

on _
end _

on submenu_MoviePlayerMenu
   return "Global | Movie | Video | Menu"
end submenu_MoviePlayerMenu

on submenu_Capture
   return "Global | Movie | Capture | Menu"
end submenu_Capture

on submenu_RecordMovie
   return "Global | Movie | Record | Menu"
end submenu_RecordMovie

on submenu_BookMarkMenu
   return "Global | Movie | Bookmarks | Menu", subMenu
end submenu_BookMarkMenu

on submenu_MovieCallMenu
   return "Global | Movie | Call | Menu"
end submenu_MovieCallMenu

on submenu_QuickTime
   return "Global | QuickTime | Menu"
end submenu_QuickTime

on submenu_MovieTools
   return "Movie | Tools | Menu"
end submenu_MovieTools

on submenu_MovieWindowMenu
   return "Global | Movie | Window | Menu"
end submenu_MovieWindowMenu

