script "lib_VLC"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_VLC
type: library
version: 0.1

/*
This library is for working on the remote control and interaction with VLC.
# start VLC's control HTTPD service on a specific port
vlc --intf http --http-host 10.1.1.156:9090

> set volume level to <val> (can be absolute integer, percent or +/- relative value):

?command=volume&val=<val>
Allowed values are of the form:
+<int>, -<int>, <int> or <int>%
*/

--> Variables
-
local LocalArray


--> Working on
-
function vlc_FetchImage
   -- can't figure what 1630268817986 is?
   put "http://192.168.0.10:8080/art?1630268817986" into someURL
   put url someURL into someImage
   return someImage
end vlc_FetchImage

getprop vlc_VlmArray
   -- seems empty
   put the long id of the target into tObject
   put _GetTermArray (tObject, "vlm") into sArray
   return sArray
end vlc_VlmArray

getprop vlc_BrowseArray
   -- seems empty
   -- ?dir=Folder                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   put the long id of the target into tObject
   put _GetTermArray (tObject, "browse") into sArray
   return sArray
end vlc_BrowseArray


--> Props
-
getprop vlc_ToggleFullScreen
   put the vlc_RestJSON ["fullscreen"] of the target into sJSON
   put json_ToArray (sJSON) into sArray
   return sArray
end vlc_ToggleFullScreen

getprop vlc_PlayListArray
   --  http://127.0.0.1:9090/requests/playlist.json
   put the long id of the target into tObject
   put _GetTermArray (tObject, "playlist") into sArray
   /*
   put the vlc_IP of tObject into vlcIP
   put the vlc_Port of tObject into vlcPort
   --
   put _RestRoot (vlcIP, vlcPort, "requests/playlist.json") into restURL
   --
   put the vlc_Secret of tObject into pWord
   put vlc_RestGet (restURL, pWord) into sJSON
   --
   put json_ToArray (sJSON) into sArray
   */
   return sArray
end vlc_PlayListArray

getprop vlc_StatusArray [sJSON]
   if sJSON is empty then
      put the long id of the target into tObject
      put the vlc_RestURL of tObject into restURL
      put the vlc_Secret of tObject into pWord
      --
      put vlc_RestGet (restURL, pWord) into sJSON
   end if
   --
   put json_ToArray (sJSON) into sArray
   return sArray
end vlc_StatusArray

getprop vlc_RestURL [urlParam]
   -- urlParam = command=pCommand&val=pVal
   put the long id of the target into tObject
   --
   put the vlc_IP of tObject into vlcIP
   put the vlc_Port of tObject into vlcPort
   --
   put _RestURL (urlParam, vlcIP, vlcPort) into restURL
   return restURL
end vlc_RestURL

private function _GetTermArray tObject, sTerm
   put the vlc_IP of tObject into vlcIP
   put the vlc_Port of tObject into vlcPort
   --
   put merge ("requests/[[sTerm]].json") into requestBit
   put _RestRoot (vlcIP, vlcPort, requestBit) into restURL
   --
   put the vlc_Secret of tObject into pWord
   put vlc_RestGet (restURL, pWord) into sJSON
   --
   put json_ToArray (sJSON) into sArray
   return sArray
end _GetTermArray

private function _RestRoot vlcIP, vlcPort, pRequestBit
   --  put merge ("http://[[vlcIP]]:[[vlcPort]]/requests/status.xml") into restURL
   if pRequestBit is empty then
      put "requests/status.json" into pRequestBit
   end if
   put merge ("http://[[vlcIP]]:[[vlcPort]]/[[pRequestBit]]") into restRoot
   return restRoot
end _RestRoot

private function _RestURL urlParam, vlcIP, vlcPort, pRequestBit
   put _RestRoot (vlcIP, vlcPort, pRequestBit) into restURL
   if urlParam is empty then
      return restURL
   else
      return restURL & urlParam
   end if
end _RestURL

command vlc_StoreMark @markData, statusArray
   put vlc_GetState (statusArray) into playState
   switch playState
      case "paused"
         put vlc_GetTime (statusArray) into sTime
         put vlc_GetPosition (statusArray) into markData [sTime]["position"]
         put vlc_GetKeyFrameFile (statusArray) into markData [sTime]["keyframe"]
         --
         break
      case "playing"
         break
   end switch
   return sTime
end vlc_StoreMark


--> VLC | Mark
-
setprop vlc_MarkIn sTime
   put the long id of the target into mObject
   --
   put the movie_ID of mObject into moveID
   put sTime into markArray ["inTime"]
   vlc_Mark markArray, moveID, mObject
   return the result
end vlc_MarkIn

setprop vlc_MarkOut sTime
   set the vlc_Mark ["markIn"] of the target to sTime
end vlc_MarkOut

command vlc_Mark markArray, moveID, mObject, pIndexNum
   put the vlc_MarkData [moveID] of mObject into markData
   if pIndexNum is empty then
      put item 2 of the extents of markData + 1 into pIndexNum
   end if
   --
   put markArray into markData [nextNum][markType]
   -- 
   set the vlc_MarkData [pMoveID] of mObject to markData
   return nextNum
end vlc_Mark

getprop vlc_MarkData [pMoveID]
   if pMoveID is empty then return empty
   
   put the vlc_Value ["markData"] of the target into markModel
   return markModel [pMoveID]
end vlc_MarkData

setprop vlc_MarkData [pMoveID] markData
   if pMoveID is empty then return empty
   
   put the vlc_MarkModel of the target into markModel 
   put markData into markModel [pMoveID]
   set the vlc_MarkModel of the target to markModel 
   return the result
end vlc_MarkData

getprop vlc_MarkModel
   put the vlc_Value ["markData"] of the target into markModel
   return markModel
end vlc_MarkModel

setprop vlc_MarkModel markModel
   set the vlc_Value ["markData"] of the target to markModel 
   return the result
end vlc_MarkModel


--> VLC | Model | Get
-
function vlc_GetTime statusArray
   return statusArray ["time"]
end vlc_GetTime

function vlc_GetPosition statusArray
   return statusArray ["position"]
end vlc_GetPosition

function vlc_GetState statusArray
   return statusArray ["state"]
end vlc_GetState

function vlc_GetKeyFrameFile statusArray
   put statusArray ["information"]["category[1]"]["info[3]"] into sFile
   return sFile
end vlc_GetKeyFrameFile


--> Props
-
getprop vlc_TogglePause
   put the vlc_RestJSON ["pl_pause"] of the target into sJSON
   put json_ToArray (sJSON) into sArray
   return sArray
end vlc_TogglePause

setprop vlc_Seek sTime
   /*
   ?command=seek&val=<val>
   
   # Allowed values are of the form:
   [+ or -][<int><H or h>:][<int><M or m or '>:][<int><nothing or S or s or ">]
   or [+ or -]<int>%
   (value between [ ] are optional, value between < > are mandatory)
   examples:
   1000 -> seek to the 1000th second
   +1H:2M -> seek 1 hour and 2 minutes forward
   -10% -> seek 10% back
   */
   set the vlc_RestJSON ["seek"] of the target to sTime
   return the result
end vlc_Seek


--> Props | Model
-
getprop vlc_ModelName
   -- a default (overide in app)
   return "Pigeon"
end vlc_ModelName

getprop vlc_IP
   put the vlc_Value ["someIP"] of the target into someIP
   if someIP is empty then
      return "127.0.0.1"
   else
      return someIP
   end if
end vlc_IP

setprop vlc_IP someIP
   set the vlc_Value ["someIP"] of the target to someIP
   return the result
end vlc_IP

getprop vlc_Port
   put the vlc_Value ["somePort"] of the target into somePort
   if somePort is empty then
      return "8080"
   else
      return somePort
   end if
end vlc_Port

setprop vlc_Port somePort
   set the vlc_Value ["somePort"] of the target to somePort
   return the result
end vlc_Port

getprop vlc_Value [sKey]
   put the vlc_Model of the target into mData
   return mData [sKey]
end vlc_Value

setprop vlc_Value [sKey] sValue
   -- simplify
   put the vlc_Model of the target into mData
   put sValue into mData [sKey]
   set the vlc_Model of the target to mData
   return mData
end vlc_Value

getprop vlc_Model
   put the vlc_ModelName of the target into mStackName
   return vlc_GetModel (mStackName)
end vlc_Model

setprop vlc_Model mData
   put the vlc_ModelName of the target into mStackName
   vlc_SetModel mStackName, mData
   return mStackName
end vlc_Model

function vlc_GetModel mStackName
   return LocalArray [mStackName]
end vlc_GetModel

command vlc_SetModel mStackName, modelData
   put modelData into LocalArray [mStackName]
end vlc_SetModel


--> VLC | Rest
-
getprop vlc_RestJSON [pCommand]
   put the long id of the target into tObject
   put _ConstructUrlParam (pCommand) into urlParam
   --
   put the vlc_RestURL [urlParam] of tObject into restURL
   --
   put the vlc_Secret of tObject into pWord
   put vlc_RestGet (restURL, pWord) into statusXML
   return statusXML
end vlc_RestJSON

setprop vlc_RestJSON [pCommand] pValue
   put the long id of the target into tObject
   put _ConstructUrlParam (pCommand, pValue) into urlParam
   --
   put the vlc_RestURL [urlParam] of tObject into restURL
   --
   put the vlc_Secret of tObject into pWord
   put vlc_RestGet (restURL, pWord) into statusXML
   return statusXML
end vlc_RestJSON

private function _ConstructUrlParam pCommand, pVal
   if pCommand is empty then return empty
   
   put "?command=" & pCommand into urlParam
   if pVal is not empty then
      put "&val=" & pVal after urlParam
   end if
   return urlParam
end _ConstructUrlParam

function vlc_RestGet restURL, pWord
   put empty into uName
   --
   http_SetBasicAuthentication uName, pWord
   get url restURL
   return it
end vlc_RestGet


--> Private
-
command http_SetBasicAuthentication someUser, somePassWord, moreHeaders
   put someUser & ":" & somePassWord into tToken
   put format("Authorization: Basic %s", base64encode(tToken)) into someHeaders
   if moreHeaders is not empty then
      put CR & moreHeaders after someHeaders
   end if
   set the httpheaders to someHeaders
end http_SetBasicAuthentication
