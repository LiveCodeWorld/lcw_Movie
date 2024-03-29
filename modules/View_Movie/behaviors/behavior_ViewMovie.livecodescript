﻿script "behavior_ViewMovie"
--> MetaData
-
author: David Bovill
copyright: David Bovill
name: behavior_ViewMovie
license: GPLv3
type: behavior
version: 0.2

/*
This view displays a video.
*/

local LocalArray


--> Working on
-
getprop displayed_Data
   put the movie_File of me into mFile
   return mFile
end displayed_Data

setprop displayed_Data mFile
   set the movie_File of me to mFile
   return the result
end displayed_Data

setprop youtube_ID videoID
   put youtube_HtmlEmbed (videoID) into iframeHTML
   put html_GetIframeSrc (iframeHTML) into videoURL
   put "https:" before videoURL
   --
   set the browser_URL of me to videoURL
   -- set the browser_Html of me to iframeHTML
   return videoURL
end youtube_ID

setprop vimeo_ID videoID
   put vimeo_HtmlEmbed (videoID) into iframeHTML
   put html_GetIframeSrc (iframeHTML) into videoURL
   --
   set the browser_URL of me to videoURL
   -- set the browser_Html of me to iframeHTML
   return videoURL
end vimeo_ID

on FillInData pDataA, pRow
   -- pDataA ["@style"]
   -- "VIMEO 229827899\n(double-click to edit caption)\n"
   -- "HTML5 MP4 http://liquidlaw.org/assets/Legislative_Theatre_Animated_Presentation.mp4#t=01:08,02:08\n[[History of Legislative Theatre]]. Pekarna Magdalenske mreže, Pracownia Inspiracji Społecznych, Active Inquiry, Cooperativa Giolli. Animationsby : Lucija Smodiš, Brina Fekonja - [https://legilab4progress.wixsite.com/legilab4progress LegiLAB (2018)]"
   
   
   put word 1 to -1 of pDataA ["text"] into itemText
   switch word 1 of itemText
      case "VIMEO"
         put word 2 of itemText into videoID
         set the vimeo_ID of me to videoID
         break
      case "YOUTUBE"
         put word 2 of itemText into videoID
         set the youtube_ID of me to videoID
         break
      case "HTMML5"
         put word 2 of itemText into mimeType
         put word 3 to -1 of line 1 of itemText into videoURL
         --
         --  set the movie_File of me to videoURL
         set the browser_URL of me to videoURL
         break
      default
         set the movie_File of me to empty
   end switch
end FillInData

getProp dvRowControl
  return the long id of me
end dvRowControl

setProp dvHilite [pHiliteColor] pBoolean
   if pBoolean then
      set the backgroundcolor of _BackgroundObject() to "purple"
   else
      set the backgroundcolor of _BackgroundObject() to pHiliteColor
   end if
end dvHilite


--> Events | Drag
-
on dragDrop
   drop_Video
   pass dragDrop
end dragDrop

on dragEnter
   set the allowableDragActions to "link"
   set the dragAction to "Link"
   pass dragEnter
end dragEnter


--> Drop
-
command drop_Video
   put the keys of the dragData into dropKeys
   --
   put the dragData ["text"] into droppedURL
   put the dragData ["html"] into droppedHTML
   put "<p><a href='(.+\.html)'>.+</a></p>" into wikiHtmlURlReg
   replace "'" with quote in wikiHtmlURlReg
   --
   switch
      case droppedURL begins with "https://www.c-span.org/video/?"
         drop_Youtube droppedURL
         break
      case "Files" is among the lines of dropKeys
         put the dragData ["files"] into dFiles
         drop_File dFiles
         break
      case "image" is among the lines of dropKeys
         put the dragData ["image"] into imageContents
         put "image" & CR & line 1 of imageContents
         break
      case droppedURL begins with "https://www.bbc.co.uk/iplayer/episode/"
      case matchtext (droppedURL, "https://www.bbc.co.uk/iplayer/episode/(.+)")
         drop_BBC droppedURL
         break
      case droppedURL begins with "https://www.youtube.com/watch?v="
      case matchText (droppedURL, "https://www.youtube.com/watch?v=(.+)", tubeID)
         drop_Youtube droppedURL
         break
      case matchText (droppedURL, "https://vimeo.com/(.+)", vimeoID)
      case matchText (droppedURL, "https://vimeo.com/channels/staffpicks/(.+)", vimeoID)
         drop_Vimeo vimeoID
         break
      case matchText (droppedHTML, wikiHtmlURlReg, wikiHtmlURl)
         drop_WikiHtmlUrl wikiHtmlURl
         break
      default
         -- do nothing
         answer warning "I don't recognise this url!"
         put droppedURL
         break
      default
         put dropKeys
   end switch
end drop_Video

command drop_Vimeo vimeoID
   put vimeoID
end drop_Vimeo

command drop_Youtube youTubeURL
   -- https://www.youtube.com/watch?v=BvDpNtbrr5Y
   put youtube_ListFormats (youTubeURL) into availableFormats
   switch
      case availableFormats contains "webm"
         youtube_DownloadVideo youTubeURL, "webm", true
         break
      case availableFormats contains "ogg"
         youtube_DownloadVideo youTubeURL, "ogg", true
         break
      default
         youtube_DownloadVideo youTubeUrl, "mp4", true
   end switch   
   put the result into videoFile
   set the movie_File of me to videoFile
   return videoFile
end drop_Youtube

command drop_WikiHtmlUrl wikiHtmlURl
   --http://david.dojo.fed.wiki/today-i-write.html
   
   put "http://(.+)\/(.+)\.html" into someReg
   if matchText (wikiHtmlURl, someReg, wikiDomain, pageSlug) is true then
      put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
      --
      put pageArray ["title"]
      put pageArray ["story"] into storyArray
      repeat with itemNum = 1 to item 2 of the extents of storyArray
         put storyArray [itemNum]["type"] into itemType
         switch itemType
            case "video"
            case "audio"
               put storyArray [itemNum]["text"] into itemText
               put line 1 of itemText into mediaLine
               put mediaLine & CR after mediaLines
               break
            default
               next repeat
         end switch
      end repeat
      put mediaLines
   else
      return empty
   end if
end drop_WikiHtmlUrl

command drop_BBC droppedURL
   -- Horizon_2020_-_Pluto_Back_From_the_Dead_m000kqm9_original.mp4
   set the cursor to watch
   iplayer_DownloadVideo droppedURL
   put the result into episodeTitle
   
   ## Now add it to player
   put item -1 of episodeTitle into programID
   put iplayer_GetInfo (programID) into infoArray
   display_Data infoArray
   
   put iplayer_GetDownloadFolder() into iplayerFolder
   finder_Reveal iplayerFolder
end drop_BBC

command drop_File dFiles
   if dFiles is empty then
      put line 1 of dragData ["files"] into videoFile
   else
      put line 1 of dFiles into videoFile
   end if
   --
   switch
      case file_IsVideo (videoFile)
         set the movie_File of me to videoFile
         set the movie_Paused of me to false
         break
      case videoFile ends with ".m3u"
         put url ("file:" & videoFile) into m3uPlayList
         set the m3u_Text of me to m3uPlayList
         break
      default
         put "Dropped file:" && videoFile
   end switch
end drop_File


--> Geometry
-
on resizeControl
   LayoutControl the rect of me
   pass resizeControl
end resizeControl

setprop view_Rect someRect
   -- here to force a redraw when rect has not changed
   LayoutControl
end view_Rect

on LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   --
   put the movie_Player of me into moviePlayer
   put the menu_Button of me into mButton
   put _BackgroundObject() into backgroundObject
   put _BrowserObject() into browserObject
   
   lock screen
   put the inner_Rect [pRect] of me into backgroundObjectRect
   put the media_Rect [backgroundObjectRect] of moviePlayer into movieRect
   if movieRect is empty then
      -- in case library is not in use
      put backgroundObjectRect into movieRect
   end if
   
   set the rect of me to pRect -- in case it's locked
   --
   set the rect of moviePlayer to movieRect
   set the rect of browserObject to movieRect
   --
   set the rect of mButton to backgroundObjectRect
   set the rect of backgroundObject to backgroundObjectRect
   unlock screen
   
   focus on moviePlayer
end LayoutControl


--> Browser
-
getprop browser_Html
   put _BrowserObject() into bObject
   put the htmltext of bObject into someHTML
   return someHTML
end browser_Html

setprop browser_Html [dontShow] someHtml
   put _BrowserObject() into bObject
   lock screen
   set the htmltext of bObject to someHTML
   if dontShow is not true then
      set the show_Browser of bObject to true
   end if
   unlock screen
   return bObject
end browser_Html

getprop browser_URL
   put _BrowserObject() into bObject
   put the url of bObject into someURL
   return someURL
end browser_URL

setprop browser_URL [dontShow] someURL
   put _BrowserObject() into bObject
   lock screen
   set the url of bObject to someURL
   if dontShow is not true then
      set the show_Browser of bObject to true
   end if
   unlock screen
   return bObject
end browser_URL

getprop show_Browser
   put the visible of _BrowserObject() into isShowing
   return isShowing
end show_Browser

setprop show_Browser isShowing
   lock screen
   set the visible of _BrowserObject() to (isShowing is true)
   set the visible of _PlayerObject() to (isShowing is false)
   unlock screen
end show_Browser


--> Events
-
on keyDown kName
   switch kName
      case "i"
         put the movie_Seconds of me into mSeconds
         set the clip_StartTime of me to mSeconds
         break
      case "o"
         put the movie_Seconds of me into mSeconds
         set the clip_EndTime of me to mSeconds
         break
      default
         pass keyDown
   end switch
end keyDown

on arrowkey pKey
   put the long id of me into pObject
   put the currenttime of pObject into sTime
   put the timescale of pObject into oneSecond
   --
   switch
      case the optionkey is "down"
         put 2*oneSecond into oneSecond
         break
      case the commandkey is "down"
         put 5*oneSecond into oneSecond
         break
   end switch
   --
   switch pKey
      case "up"
         put the clip_StartTime ["raw"] of me into sTime
         if sTime > 0 then
            set the currenttime of pObject to sTime
         end if
         break
      case "down"
         put the clip_EndTime ["raw"] of me into eTime
         if eTime > 0 then
            set the currenttime of pObject to eTime
         end if
         break
      case "left"
         if the optionKey is "down" then
            put (sTime - oneSecond) into newTime
         else
            put (sTime - 1) into newTime
         end if
         set the currenttime of pObject to newTime
         break
      case "right"
         if the optionKey is "down" then
            put (sTime + oneSecond) into newTime
         else
            put (sTime + 1) into newTime
         end if
         set the currenttime of pObject to newTime
         break
      default
         pass arrowkey
   end switch
end arrowkey

on currentTimeChanged newTime
   put the event_Message [newTime]  of me into messageName
   if messageName is empty then pass currentTimeChanged
   
   set the movie_Paused of me to true
   put messageName
   do messageName
end currentTimeChanged


--> m3u
-
command m3u_Play m3uText
   if line 1 of m3uText is not "#EXTM3U" then return empty
   delete line 1 of m3uText
   put the number of lines of m3uText into maxNum
   if maxNum mod 2 > 1 then return empty
   put maxNum / 2 into pairNum
   --
   set the itemdelimiter to ":"
   repeat pairNum
      _DeconstructEXTINF extinfLine, shortFile
      put the result into trackDuration
      if trackDuration = 0 then
         breakpoint
         return empty
      end if
      
      get line 2 of m3uText
      switch item 1 of it
         case "file"
            put it into someURl
            break
         case "url"
            
            break
         default
            -- Meta-physical%20Wobbles.mp3
            put it into urlEncodedShortFile
      end switch
      
      delete line 1 to 2 of m3uText
   end repeat
end m3u_Play


--> Props
-
getprop m3u_Text
   put LocalArray ["m3u_Text"] into m3uText
   return m3uText
end m3u_Text

setprop m3u_Text m3uText
   put m3uText into LocalArray ["m3u_Text"]
   m3u_Play m3uText
end m3u_Text

getprop melt_Array [shotcutCaption]
   if shotcutCaption is empty then put "First Clip" into shotcutCaption
   put the movie_Player of the target into mPlayer
   --
   put the filename of mPlayer into movieFile
   --
   put the clip_StartTime ["hms"] of mPlayer into inClipTime
   put the clip_EndTime ["hms"] of mPlayer into outClipTime
   --
   put melt_ConstructArray (movieFile, inClipTime, outClipTime, shotcutCaption) into mltArray
   return mltArray
end melt_Array


--> Movie | Time
-
getprop movie_HMS
   put the movie_Seconds of me into movieSeconds
   put time_SecondsToHMS (movieSeconds) into hms
   return hms
end movie_HMS

getprop movie_HMSF
   put the movie_Seconds of me into movieSeconds
   
   put time_SecondsToHMSF(movieSeconds) into hmsf
   --
   return hmsf
end movie_HMSF

setprop movie_HMSF hmsf
   set the movie_Seconds of the target to hmsf
end movie_HMSF

getprop movie_Seconds
   put the movie_Player of the target into moviePlayer
   
   put the timescale of moviePlayer into someScale
   if someScale = 0 then return empty
   put the currenttime of moviePlayer / someScale into movieSeconds
   return movieSeconds
end movie_Seconds

setprop movie_Seconds movieSeconds
   put the movie_Player of the target into moviePlayer
   
   switch movieSeconds
      case "end"
         put the duration of moviePlayer into movieTime
         set the currenttime of moviePlayer to movieTime
         break
      case "start"
         set the currenttime of moviePlayer to 0
         break
      default
         put the timescale of moviePlayer into someScale
         put round (movieSeconds * someScale) into movieTime
         set the currenttime of moviePlayer to movieTime
   end switch
   focus on moviePlayer
end movie_Seconds

getprop movie_Time
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   put the currenttime of moviePlayer into cTime
   return cTime
end movie_Time

setprop movie_Time cTime
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   if movieTime is "end" then
      put the duration of moviePlayer into movieEndTime
      set the currenttime of moviePlayer to movieEndTime
   else if cTime is among the items of "start,beginning" then
      set the currenttime of moviePlayer to 0
   else
      set the currenttime of moviePlayer to cTime
   end if
   focus on moviePlayer
end movie_Time

getprop movie_Duration [useSpotLight]
   -- not quite the same as shotcut duration :(
   put the movie_Player of the target into moviePlayer
   if useSpotLight is true then
      put the filename of moviePlayer into movieFile
      put spotlight_GetMovieDurationInSeconds (movieFile) into movieSeconds
   else
      put the timescale of moviePlayer into someScale
      put the duration of moviePlayer / someScale into movieSeconds
   end if
   --
   put time_SecondsToHMSF (movieSeconds) into hmsf
   --
   return hmsf
end movie_Duration

getprop movie_Hash
   put the movie_Player of the target into moviePlayer
   put the filename of moviePlayer into movieFile
   --
   put file_Md5Hash (movieFile) into movieHash
   --
   return movieHash
end movie_Hash

getprop shotcut_Hash
   -- A MD5 hash of a media file (whole file if less than 2 MB, or first MB followed by last MB for files larger than 2 MB)
   put the movie_Player of the target into moviePlayer
   put the filename of moviePlayer into movieFile
   --
   put melt_GetShotCutHash (movieFile) into movieHash
   --
   return movieHash 
end shotcut_Hash

getprop file_Tail [pMbNum]
   -- Using the -c switch (2MB = 2 * 1024 * 1024 = 2097152 bytes):
   -- tail -c 2097152 myapp.log      
   -- tail -c 2m myapp.log
   
   put the movie_Player of the target into moviePlayer
   put the filename of moviePlayer into movieFile
   --
   put file_GetTail (movieFile, pMbNum) into lastMB
   --
   return lastMB
end file_Tail

getprop file_Head [pMbNum]
   -- head -c 2M input.file
   put the movie_Player of the target into moviePlayer
   put the filename of moviePlayer into movieFile
   --
   put file_GetHead (movieFile, pMbNum) into firstMB
   --
   return firstMB
end file_Head


--> Events | Props
-
getprop event_Array [newTime]
   put LocalArray ["events"] into eventArray
   if newTime is empty then return eventArray
   
   put eArray [newTime] into messageArray
   return messageArray
end event_Array

setprop event_Array [newTime] eventArray
   if newTime is empty then
      put eventArray into LocalArray ["events"]
      return eventArray
   end if
   
   put eventArray into LocalArray ["events"][newTime]
   put LocalArray ["events"] into eventArray
   return eventArray
end event_Array

getprop event_Message [newTime] 
   put LocalArray ["events"][newTime]["messageName"] into messageName
   return messageName
end event_Message

setprop event_Message [newTime] messageName
   if messageName is empty then
      delete variable LocalArray ["events"][newTime]
   else
      put messageName into LocalArray ["events"][newTime]["messageName"]
   end if
   return LocalArray ["events"]
end event_Message


--> Movie
-
getprop movie_ControllerID
   put the movie_Player of the target into moviePlayer
   return the moviecontrollerid of moviePlayer
end movie_ControllerID

getprop movie_File
   put the movie_Player of the target into moviePlayer
   put the filename of moviePlayer into mFile
   return mFile
end movie_File

setprop movie_File [dontShow] someFile
   put the movie_View of the target into movieView
   if exists(movieView) is false then return empty
   
   put the rect of movieView into oRect
   put the movie_Player of movieView into moviePlayer
   
   if there is a folder someFile then
      set the itemdelimiter to "."
      put item -1 of someFile into fileExtension
      if fileExtension is among the items of "eyetv.eyetv/" then
         set the eyetv_Bundle of movieView to someFile
         return the result
      end if
   end if
   
   lock screen
   put the filename of moviePlayer into oldFile
   if oldFile = someFile then
      -- to force movie to reload
      set the filename of moviePlayer to empty
   end if
   set the filename of moviePlayer to someFile
   LayoutControl oRect
   --
   if dontShow is not false then
      set the show_Browser of me to false
   end if
   --
   focus on moviePlayer
   unlock screen
end movie_File


--> Movie | Clip | Old
-
getprop movie_Paused
   return the paused of the movie_Player of the target
end movie_Paused

setprop movie_Paused someBoolean
   put the movie_Player of the target into moviePlayer
   set the paused of moviePlayer to someBoolean
   focus on moviePlayer
end movie_Paused

getprop movie_PlayRate
   return the playrate of the movie_Player of the target
end movie_PlayRate

setprop movie_PlayRate someRate
   put the movie_Player of the target into moviePlayer
   set the playrate of moviePlayer to someRate
   focus on moviePlayer
end movie_PlayRate

getprop movie_PlaySelection
   return the playselection of the movie_Player of the target
end movie_PlaySelection

setprop movie_PlaySelection someBoolean
   set the playselection of the movie_Player of the target to someBoolean
end movie_PlaySelection

getprop movie_ShowSelection
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   put the showselection of moviePlayer into someBoolean
   return someBoolean
end movie_ShowSelection

setprop movie_ShowSelection someBoolean
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   set the showselection of moviePlayer to someBoolean
   return moviePlayer
end movie_ShowSelection

getprop movie_ControllerShowing
   put the movie_View of the target into movieView
   put the movie_Player of movieView into moviePlayer
   put the movie_Controller of movieView into movieController
   
   if exists(movieController) then
      return the visible of movieController
   else
      return the showcontroller of moviePlayer
   end if
end movie_ControllerShowing

setprop movie_ControllerShowing someBoolean
   put the movie_View of the target into movieView
   put the movie_Player of movieView into moviePlayer
   put the movie_Controller of movieView into movieController
   
   if exists(movieController) then
      set the visible of movieController to not someBoolean
      -- set the showcontroller of moviePlayer to someBoolean
      set the alwaysbuffer of moviePlayer to not someBoolean
   else
      lock screen
      set the showcontroller of moviePlayer to someBoolean
      -- set the alwaysbuffer of moviePlayer to not someBoolean
      LayoutControl
      unlock screen
   end if
end movie_ControllerShowing


--> Clip
-
getprop clip_Duration [tFormat]
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   switch tFormat
      case "raw"
         put the endtime of moviePlayer - the starttime of moviePlayer into clipDuration
         break
      case "hmsf"
      case "true"
         put the timescale of moviePlayer into someScale
         put (the endtime of moviePlayer - the starttime of moviePlayer) / someScale into dTime
         put time_SecondsToHMSF (dTime) into clipDuration
         break
      default
         -- case false
         -- case "s"
         -- case "seconds"
         put the timescale of moviePlayer into someScale
         put (the endtime of moviePlayer - the starttime of moviePlayer) / someScale into clipDuration
   end switch
   return clipDuration
end clip_Duration

getprop clip_StartTime [tFormat]
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   switch tFormat
      case "raw"
         put the startTime of moviePlayer into sTime
         return sTime
      case "hmsf"
      case "true"
         put the timescale of moviePlayer into someScale
         put the starttime of moviePlayer into sTime
         put sTime / someScale into startTimeInSeconds
         put time_SecondsToHMSF (startTimeInSeconds) into startTimeInHMSF
         return startTimeInHMSF
      case "hms"
         put the timescale of moviePlayer into someScale
         put the starttime of moviePlayer into sTime
         put sTime / someScale into startTimeInSeconds
         put time_SecondsToHMS (startTimeInSeconds) into startTimeInHMS
         return startTimeInHMS
      default
         put the timescale of moviePlayer into someScale
         put the starttime of moviePlayer into sTime
         put sTime / someScale into startTimeInSeconds
         return startTimeInSeconds
   end switch
end clip_StartTime

setprop clip_StartTime [tFormat] sTime
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   switch tFormat
      case "raw"
         put sTime into cTime
         break
      case "true"
      case "hmsf"
         put the timescale of moviePlayer into someScale
         put time_HmsfToSeconds (sTime) into mSeconds
         put mSeconds * someScale into cTime
         break
      default
         -- case false
         -- case "s"
         -- case "seconds"
         put sTime into mSeconds
         put the timescale of moviePlayer into someScale
         put mSeconds * someScale into cTime
   end switch
   
   set the startTime of moviePlayer to cTime
   return moviePlayer
end clip_StartTime

getprop clip_EndTime [tFormat]
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   switch tFormat
      case "raw"
         put the endTime of moviePlayer into eTime
         return eTime
      case "hms"
         put the timescale of moviePlayer into someScale
         put the endTime of moviePlayer / someScale into movieSeconds
         put time_SecondsToHMS (movieSeconds) into endTimeInHMS
         return endTimeInHMS
      case "hmsf"
      case "true"
         put the timescale of moviePlayer into someScale
         put the endTime of moviePlayer / someScale into movieSeconds
         put time_SecondsToHMSF (movieSeconds) into endTimeInHMSF
         return endTimeInHMSF
      default
         -- case false
         -- case "s"
         -- case "seconds"
         put the timescale of moviePlayer into someScale
         put the endTime of moviePlayer into eTime
         put eTime / someScale into endTimeInSeconds
         return endTimeInSeconds
   end switch
end clip_EndTime

setprop clip_EndTime [tFormat] eTime
   put the movie_Player of the target into moviePlayer
   if exists(moviePlayer) is false then return empty
   
   switch tFormat
      case "raw"
         put eTime into cTime
         break
      case "true"
      case "hmsf"
         put the timescale of moviePlayer into someScale
         put time_HmsfToSeconds (eTime) into mSeconds
         put mSeconds * someScale into cTime
         break
         -- case false
         -- case "s"
         -- case "seconds"
      default
         put eTime into mSeconds
         put the timescale of moviePlayer into someScale
         put mSeconds * someScale into cTime
   end switch
   
   set the endTime of moviePlayer to cTime
   return moviePlayer
end clip_EndTime


--> Events
-
/*
on mouseDown
   trigger_Event the params
   pass mouseDown
end mouseDown

on mouseUp
   trigger_Event the params
   pass mouseUp
end mouseUp

on mouseDoubleUp
   trigger_Event the params
   pass mouseDoubleUp
end mouseDoubleUp

on mouseRelease
   trigger_Event the params
   pass mouseRelease
end mouseRelease

on playStarted
   set the movie_DisplayPaused of me to false
end playStarted

on playStopped
   set the movie_DisplayPaused of me to true
end playStopped

on playPaused
   /*
   Bug in that set the paused of player to true does not generate message while false is
   Need to manually set in any controllers and not rely on this message being sent!
   */
   set the movie_DisplayPaused of me to true
end playPaused
*/


--> Objects
-
-- getprop menu_Button
return the long id of button "_Menu Button" of me
end menu_Button

getprop movie_View
   return the long id of me
end movie_View

getprop view_Object
   return the long id of me
end view_Object

getprop movie_Player
   return _PlayerObject()
end movie_Player


--> Private | Objects
-
private function _BackgroundObject
   -- could be a graphic?
   return the long id of control "_View Background" of me
end _BackgroundObject

private function _BrowserObject
   put the long id of widget "_Movie Browser" of me into mBrowser
   return mBrowser
end _BrowserObject

private function _PlayerObject
   put the long id of player 1 of me into mPlayer
   return mPlayer
end _PlayerObject


--> Private
-
private command _DeconstructEXTINF extinfLine, @shortFile
   -- #EXTINF:155,Lovelock robot talk.mp4
   set the itemdelimiter to ":"
   if item 1 of extinfLine is not "#EXTINF" then
      breakpoint
      return 0
   end if
   
   get item 2 of extinfLine
   set the itemdelimiter to comma
   put item 1 of it into trackDuration -- track information: runtime in seconds and display title of the following resourc
   put item 2 of it into shortFile
   return trackDuration
end _DeconstructEXTINF

function file_IsVideo someFile, quickSearch, beAggressive
   set the itemdelimiter to "."
   if the platform = "MacOS" then
      put "file -I" && kwote (someFile) into someShell
      put shell (someShell) into shellReply
      set the itemdelimiter to ":"
      get token 1 of item 2 of shellReply
      
      -- put spotlight_GetFileKind (someFile) into fileKind
      if it is "video" then
         return true
      else
         return false
      end if
   else if item -1 of someFile is among the items of "mov.mp4.avi.mpg.m4v" then
      return true
   else
      return false
   end if
end file_IsVideo

function time_HmsfToSeconds hmsf, pFramesPerSecond
   if pFramesPerSecond is not a number then
      put 25 into pFramesPerSecond
   end if
   
   set the itemdelimiter to ":"
   put item 1 of hmsf into someHours
   put item 2 of hmsf into someMinutes
   put item 3 of hmsf into someSeconds
   put item 4 of hmsf into someFrames
   
   add someHours * 3600 to someSeconds
   add someMinutes * 60 to someSeconds
   add someFrames / pFramesPerSecond to someSeconds
   
   return someSeconds
end time_HmsfToSeconds

function time_SecondsToHMSF someSeconds, someFrames
   put the numberformat into oFormat
   set the numberformat to "##"
   
   put someSeconds div 3600 into someHours 
   put someSeconds mod 3600 into secondsLeft
   
   put secondsLeft div 60 into someMinutes
   put secondsLeft mod 60 into secondsLeft
   
   put trunc(secondsLeft) into someSeconds
   put secondsLeft - someSeconds into someFraction
   
   if someFrames is empty then put round(someFraction * 25) into someFrames
   add 0 to someFrames
   
   get someHours & ":" & someMinutes  & ":" & someSeconds  & ":" & someFrames
   set the numberformat to oFormat
   return it
end time_SecondsToHMSF
