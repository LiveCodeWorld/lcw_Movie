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

put merge ("http://[[uName]]@[[pWord]]@127.0.0.1:8080/requests/status.xml?command=pl_stop") into vlcURL
put merge ("http://[[uName]]@[[pWord]]:127.0.0.1:8080/requests/status.xml?command=pl_pause") into vlcURL
put merge ("http://[[pWord]]:127.0.0.1:8080/requests/status.xml?command=pl_pause") into vlcURL
put "http://127.0.0.1:8080/requests/status.xml?command=pl_pause" into vlcURL

vlc_GetSecret
http://127.0.0.1:9090/requests/playlist.xml

pl_stop
pl_empty

# PLAY AN RTSP STREAM URL:
http://127.0.0.1:9090/requests/status.xml?command=in_play&input=rtsp://user:pass@somewebcameraaddress.com:9552/cam1/mpeg4

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
command vlc_Seek sTime
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
   
   put vlc_RestUrl ("seek", sTime) into restURL
   vlc_RestGet restURL
   put the result into statusXML
   return statusXML
end vlc_Seek

command vlc_TogglePause pModelName
   -- http://127.0.0.1:8080/requests/status.xml?command=pl_pause
   put vlc_RestUrl ("pl_pause") into restURL
   vlc_RestGet restURL
   put the result into statusXML
   --
   if pModelName is not empty then
      vlc_StoreMark pModelName, statusXML
   end if
   --
   return statusXML
end vlc_TogglePause


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


--> VLC | Mark | Model
-
command vlc_StoreMark modelName, pStatusXML
   if pStatusXML is empty then
      put vlc_FetchStatusArray() into statusArray
   else
      get xml_ToArray (pStatusXML)
      put it ["root"] into statusArray
   end if
   --
   put vlc_GetState (statusArray) into playState
   switch playState
      case "paused"
         put vlc_GetTime (statusArray) into sTime
         put vlc_GetPosition (statusArray) into LocalArray [modelname][sTime]["position"]
         put vlc_GetKeyFrameFile (statusArray) into LocalArray [modelname][sTime]["keyframe"]
         break
      case "playing"
         break
   end switch
   return statusArray
end vlc_StoreMark

function vlc_GetModel modelName
   return LocalArray [modelName]
end vlc_GetModel

command vlc_SetModel modelName, modelData
   put modelData into LocalArray [modelName]
end vlc_SetModel


--> VLC | Fetch
-
function vlc_FetchStatusArray
   put vlc_RestUrl() into restURL
   vlc_RestGet restURL
   put the result into pStatusXML
   get xml_ToArray (pStatusXML)
   put it ["root"] into statusArray
   return statusArray
end vlc_FetchStatusArray


--> VLC | Rest
-
function vlc_RestUrl pCommand, pVal
   put vlc_GetPort() into vlcPort
   put vlc_GetIP() into vlcIP
   put merge ("http://[[vlcIP]]:[[vlcPort]]/requests/status.xml") into restURL
   --
   if pCommand is not empty then
      put "?command=" & pCommand after restURL
      if pVal is not empty then
         put "&val=" & pVal after restURL
      end if
   end if
   return restURL
end vlc_RestUrl

command vlc_RestGet restURL
   put empty into uName
   put vlc_GetSecret() into pWord
   --
   http_SetBasicAuthentication uName, pWord
   get url restURL
   return it
end vlc_RestGet

function vlc_GetIP
   return "127.0.0.1"
end vlc_GetIP

function vlc_GetPort
   return "8080"
end vlc_GetPort


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
