script "lib_DisplayIplayer"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayIplayer
type: library
version: 0.1

/*Some help*/


--> Working on
-
on iPlayer_Drop displayView, dData
   put the dragdata ["html"] into sURL
   delete char 1 to 3 of sURL
   delete char -4 to -1 of sURL
   --
   put iplayer_Search (sURL) into sResult
   answer sResult as sheet
end iPlayer_Drop


--> TED
-
function ted_ConstructPageArray tedID
   put "https://www.ted.com/talks/" & tedID into tedURL
   --
   put html_FetchTidy (tedURL) into someHTML
   put scrape_HeaderSection (someHTML) into metaArray
   fedwiki_ParseMetaArray metaArray, htmlTitle, pageDescription, imageURL, articleTitle
   put the result into shortDescription
   --
   put articleTitle & "." && pageDescription into videoDescription
   --
   put pageArray_Construct (articleTitle, shortDescription) into fedwikiPageArray
   pageArray_AddVideo fedwikiPageArray, tedID, "TED", videoDescription
   --
   pageArray_StripJournal fedwikiPageArray
   return fedwikiPageArray
end ted_ConstructPageArray


--> Display | Iplayer | Events
-
on mDoubleUp_iPlayerSearch displayView, someLine
   set the cursor to watch
   --
   put word 1 of item -1 of someLine into programID
   delete item -1 of someLine
   set the itemdelimiter to ":"
   put item 1 of someLine into indexNum
   put item 2 to -1 of someLine into sTitle
   --
   put iplayer_GetInfo (programID) into infoArray
   put infoArray ["desclong"] into desclong
   --
   put desclong
end mDoubleUp_iPlayerSearch

on mDoubleUp_iPlayer displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
end mDoubleUp_iPlayer


--> Display | Iplayer
-
command display_SearchIplayer pSearchTerm, pDisplayView
   if pSearchTerm is empty then
      put ask_Question ("What would you like to search for?", "Prime Minister's Questions", "Search BBC  iPlayer") into pSearchTerm
   end if
   --
   put iplayer_Search (pSearchTerm) into foundIndex
   --
   display_Data foundIndex, sTerm, "iPLayer", pDisplayView, "system"
   put the result into displayView
   display_SetMouseAndMenu displayView, "iPlayer | Search", "lib_Iplayer"
   --
   set the drop_Command of displayView to "iPlayer_Drop"
   --
   return displayView
end display_SearchIplayer

command ask_DisplayIplayerSeries
   put ask_Question ("Waht series would you like to display?", "p093wp6h", "Search iPlayer") into pID
   display_IplayerSeries pID
   return the result
end ask_DisplayIplayerSeries

command display_IplayerSeries sID
   get iplayer_ListSeries (sID)
   
   set the itemdelimiter to " - "
   put item 1 of line 1 of it into seriesName
   repeat for each line sLine in it
      set the itemdelimiter to comma
      put item -1 of sLine into episodeID
      --
      get item 1 of sLine
      set the itemdelimiter to " - "
      put item 3 of it into eName
      --
      put episodeID into eArray [eName]["episodeID"]
   end repeat
   --
   display_Data eArray, seriesName, "iPlayer"
   put the result into displayView
   set the tool_MenuBit of displayView to "iPlayer"
   set the displayed_ProgramID of displayView to sID
   return displayView
end display_IplayerSeries
