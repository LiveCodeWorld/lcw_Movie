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

--> Display | VLC
-
on mDoubleUp_VLCMarks displayView, someLine
   put the selected_Path of displayView into sPath
   put item 1 of sPath into sTime
   --
   vlc_Seek sTime
end mDoubleUp_VLCMarks

command display_VlcMarks mStackName
   put vlc_GetModel (mStackName) into mData
   display_Data mData, mStackName, "VLC"
   put the result into dView
   set the data_MenuBit of dView to "VLC | Marks"
end display_VlcMarks

command display_VlcStatus mStackName
   put the vlc_StatusArray of stack mStackName into sData
   display_Data sData, "Status Array", "VLC"
end display_VlcStatus

command display_VlcPlayList mStackName
   put the vlc_PlayListArray of stack mStackName into sData
   display_Data sData, "Current Playlist", "VLC"
end display_VlcPlayList

command display_VlcBrowseArray mStackName
   put the vlc_BrowseArray of stack mStackName into sData
   display_Data sData, "Browse Array", "VLC"
end display_VlcBrowseArray


--> Deps
-

/*
function xml_ToArray pXML, pTranslateKeyBoolean, pStoreEncodedAs, pUseValueKey, pGoodXML
   -- was "xml_ConvertXmlToArray"
   local theArray, theResult, theRootNode, treeID
   local theXMLEncoding
   
   ## Create an XML tree from XML text
   put pGoodXML is true into pGoodXML
   put revXMLCreateTree (pXML, pGoodXML, true, false) into treeID
   
   if treeID is an integer then
      xml_ExtractEncoding pXML, versionMatch, theXMLEncoding
      
      ## Now convert to array.
      ## The 1st dimension has one key which is the name of the root node.
      put revXMLRootNode(treeID) into theRootNode
      if theRootNode is not empty and not (theRootNode begins with "xmlerr,") then
         put xml_ConvertXMLNodeToArray (treeID, theRootNode, theXMLEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean) into theArray [theRootNode]
      end if
      
      revXMLDeleteTree treeID
   end if
   return theArray
end xml_ToArray

function xml_ConvertXMLNodeToArray pTreeID, pNode, pXMLTreeEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean
   local theArrayA, theAttributes, theChildNode, theKey
   
   ## Look for attributes of the node. Store as array in "@attributes" key
   put revXMLAttributes (pTreeID, pNode, tab, cr) into theAttributes
   if theAttributes is not empty then
      put xml_EncodeString (theAttributes, pXMLTreeEncoding, pStoreEncodedAs) into theAttributes
      split theAttributes by cr and tab -- create array
      put theAttributes into theArrayA ["@attributes"]
   end if
   
   ## Look for children nodes.
   set the itemdelimiter to slash
   put revXMLFirstChild (pTreeID, pNode) into theChildNode
   if theChildNode is empty or theChildNode begins with "xmlerr," then
      put xml_EncodeString (revXMLNodeContents (pTreeID, pNode), pXMLTreeEncoding, pStoreEncodedAs) into theValue
      if word 1 to -1 of theValue is empty and the keys of theArrayA is not empty then
         ## Empty node that has attributes
         return theArrayA
      else if pUseValueKey then
         ## Force value into @value
         put theValue into theArrayA ["@value"]
         return theArrayA
      else
         ## Single Node with value: Return value. Attributes are ignored.
         return theValue
      end if
   else
      ## Child nodes were found. Recursively call self and store result in array.
      repeat while theChildNode is not empty and not (theChildNode begins with "xmlerr,")
         put the last item of theChildNode into theKey
         
         put xml_ConvertXMLNodeToArray (pTreeID, theChildNode, pXMLTreeEncoding, pStoreEncodedAs, pUseValueKey, pTranslateKeyBoolean) into theArrayA [theKey]
         put revXMLNextSibling (pTreeID, theChildNode) into theChildNode
      end repeat
      
      return theArrayA
   end if
end xml_ConvertXMLNodeToArray

function xml_EncodeString pString, pInEncoding, pOutEncoding
   -- Helper function for converting the encoding of strings when converting to and from XML.
   
   ## convert utf-8 to utf8 for uniencode/decode
   replace "-" with empty in pInEncoding
   replace "-" with empty in pOutEncoding
   
   if pInEncoding is not empty then
      -- if pOutEncoding is empty then pString will be converted to the current platform encoding
      return unidecode(uniencode(pString, pInEncoding), pOutEncoding)
   else
      if pOutEncoding is not empty then
         -- if pInEncoding is empty then pString is assumed to be in the current platform encoding
         return unidecode(uniencode(pString, pInEncoding), pOutEncoding)
      else
         return pString
      end if
   end if
end xml_EncodeString

command xml_ExtractEncoding someXML, @versionMatch, @xmlEncoding
   put matchtext (someXML, "<\?xml (.*)encoding=" & quote & "(.*)" & quote & "\?>", versionMatch, xmlEncoding) into theResult
   if xmlEncoding is empty then put "utf-8" into xmlEncoding
   return theResult
end xml_ExtractEncoding
*/
