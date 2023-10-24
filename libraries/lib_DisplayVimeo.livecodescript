script "lib_DisplayVimeo"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayVimeo
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Display | Vimeo
-
command vimeo_LaunchApiDocumentation
   launch url "https://developer.vimeo.com/api/guides/start"
end vimeo_LaunchApiDocumentation

on mDoubleUp_DisplayThubnail fldObject, someLine
   put the display_View of fldObject into displayView
   put the display_Dictionary of displayView into displayDictionary
   --
   if displayDictionary [someLine] is an array then
      put displayDictionary [someLine]["file"] into thumbFile
      put displayDictionary [someLine]["url"] into thumbURL
      --
      finder_Reveal thumbFile
      if the shiftKey is "Down" then
         launch url thumbURL
      end if
   else
      launch url someLine
   end if
end mDoubleUp_DisplayThubnail

command display_VimeoThumbnails vimeoID, pThumbQuality
   if pThumbQuality is emmppty then put 4 into pThumbQuality
   put vimeo_ListThumbnails (vimeoID, pThumbQuality) into thumbNailUrls
   --
   display_Data thumbNailUrls, vimeoID, "Vimeo Thumbnails", "", "system"
   put the result into displayView
   --
   display_SetInteractions displayView, "Vimeo | Thumbnails", "mDoubleUp_DisplayThubnail"
   set the thumb_Quality of displayView to pThumbQuality
   --
   return displayView
end display_VimeoThumbnails

command display_VimeoPageArray vimeoID
   put vimeo_ConstructPageArray (vimeoID) into pageArray
   if item 1 of pageArray = "error" then
      put pageArray into someError
      put someError
      return someError
   end if
   --
   display_PageArray pageArray
   --
   put the result into displayView
   return displayView
end display_VimeoPageArray

command display_VimeoData vimeoID
   if vimeoID is empty then put 229827899 into vimeoID
   --
   put vimeo_FetchVideoData (vimeoID) into vimeoData
   if item 1 of vimeoData = "error" then
      put pageArray into someError
      put someError
      return someError
   end if
   --
   display_Data vimeoData, vimeoID, "vimeo_FetchVideoData()"
   --
   put the result into displayView
   return displayView
end display_VimeoData
