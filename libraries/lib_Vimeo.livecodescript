script "lib_Vimeo"
--> MetaData
-
license: GPLv3
name: lib_Vimeo
type: library
version: 0.2

/*
This library is for interfacing with Vimeo.
Check out the documentation for the Vimeo API at:

- https://developer.vimeo.com/api/authentication
*/


--> Display
-
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


--> Workign on
-
function vimeo_ConstructTitleArray videoData
   put videoData ["data"] into pageData
   --
   repeat with itemNum = 1 to item 2 of the extents of pageData
      put pageData [itemNum] into itemArray
      vimeo_DeconstructItemArray itemArray, videoTitle, vimeoURL, uploadStatus, description, videoURL, bigPictureURL
      --
      put description into videoTitleArray [videoTitle]["description"]
      put vimeoURL into videoTitleArray [videoTitle]["vimeoURL"]
      put videoURL into videoTitleArray [videoTitle]["videoURL"]
      put uploadStatus into videoTitleArray [videoTitle]["uploadStatus"]
      put bigPictureURL into videoTitleArray [videoTitle]["bigPictureURL"]
   end repeat
   return videoTitleArray
end vimeo_ConstructTitleArray

command vimeo_DeconstructItemArray itemArray, @videoTitle, @vimeoURL, @uploadStatus, @description, @videoURL, @bigPictureURL
   put itemArray ["name"] into videoTitle
   put itemArray ["link"] into vimeoURL
   put itemArray ["status"] into uploadStatus
   put itemArray ["description"] into description
   put itemArray ["files"][1]["link"] into videoURL
   put itemArray ["pictures"]["sizes"][1]["link"] into bigPictureURL
end vimeo_DeconstructItemArray

function vimeo_GetVideoArray videoID
   put "/videos/" & videoID into apiBit
   put vimeo_RestGetArray (apiBit, true) into rArray
   return rArray
end vimeo_GetVideoArray

function vimeo_ListUserVideos pUserID
   -- GET/users/{user_id}/videos
   if pUserID is empty then
      put "/users/me/videos" into apiBit
   else
      put merge ("/users/[[pUserID]]/videos") into apiBit
   end if
   --
   put vimeo_RestGetArray (apiBit, true) into rArray
   return rArray
end vimeo_ListUserVideos

command vimeo_LaunchApiDocumentation
   launch url "https://developer.vimeo.com/api/guides/start"
end vimeo_LaunchApiDocumentation


--> Vimeo
-
function vimeo_ConstructPageArray vimeoID
   put vimeo_FetchVideoJSON (vimeoID) into someJSON
   put json_ToArray (someJSON) into vimeoArray
   --
   put vimeoArray ["error"] into someError
   if someError is not empty then
      put vimeoArray ["developer_message"] into developerMessage
      put vimeoArray ["error_code"] into errorCode
      --
      return ("error," && developerMessage)
   end if
   
   put vimeoArray ["name"] into vimeoTitle
   put vimeoArray ["description"] into vimeoDescription
   put vimeoArray ["link"] into vimeoURL
   --
   put vimeoTitle & "." && vimeoDescription into videoDescription
   --
   put pageArray_Construct (vimeoTitle, vimeoDescription) into fedwikiPageArray
   pageArray_AddVideo fedwikiPageArray, vimeoID, "VIMEO", videoDescription
   --
   return fedwikiPageArray
end vimeo_ConstructPageArray

function vimeo_FetchVideoJSON videoID
   put "videos/" & videoID into apiBit
   put vimeo_RestGET (apiBit) into someJSON
   return someJSON
end vimeo_FetchVideoJSON


--> Vimeo | Authentication
-
function vimeo_GetUnauthToken
   put secret_Get ("VimeoUnauthToken", "vimeo") into unauthToken
   return unauthToken
   
   
   -- old and not working 
   put vimeo_GetClientID() into clientID
   put vimeo_GetSecret() into clientSecret
   put base64encode (clientID & ":" & clientSecret) into encodedBit
   replace CR with empty in encodedBit
   --
   put "Authorization : basic" && encodedBit after authHeader
   set the httpheaders to authHeader
   -- 
   get libURLFormData ("grant_type", "client_credentials", "scope", "public private")
   post it to url "https://api.vimeo.com/oauth/authorize/client"
   put it into postResult
   return postResult
end vimeo_GetUnauthToken

command vimeo_SetUnauthToken unauthToken
   secret_Set "VimeoUnauthToken", unauthToken, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end vimeo_SetUnauthToken

function vimeo_GetAuthToken
   put secret_Get ("VimeoApiKey", "vimeo") into vimeoApiKey
   return vimeoApiKey
end vimeo_GetAuthToken

command vimeo_SetAuthToken accessToken
   secret_Set "VimeoApiKey", accessToken, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end vimeo_SetAuthToken


--> Vimeo | oAuth
-
function vimeo_GetClientID
   put secret_Get ("VimeoClientID", "vimeo") into vimeoApiKey
   return vimeoApiKey
end vimeo_GetClientID

command vimeo_SetClientID clientID
   secret_Set "VimeoClientID", clientID, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end vimeo_SetClientID

function vimeo_GetSecret
   put secret_Get ("VimeoClientSecret", "vimeo") into vimeoApiKey
   return vimeoApiKey
end vimeo_GetSecret

command vimeo_SetClientSecret clientSecret
   secret_Set "VimeoClientSecret", clientSecret, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end vimeo_SetClientSecret


--> Vimeo | REST
-
function vimeo_RestGetArray apiBit, pUseAuth
   put vimeo_RestGET (apiBit, pUseAuth) into rJSON
   put json_ToArray (rJSON) into rArray
   return rArray
end vimeo_RestGetArray

function vimeo_RestGET apiBit, pUseAuth
   put "https://api.vimeo.com/" & apiBit into restURL
   --
   _VimeoSetAuthHeaders pUseAuth
   put url restURL into someJSON
   return someJSON
end vimeo_RestGET


--> Private
-
private command _VimeoSetAuthHeaders pUseAuth
   if pUseAuth is true then
      put vimeo_GetAuthToken() into authToken
   else
      put vimeo_GetUnauthToken() into  authToken
   end if
   --
   put "Accept: application/vnd.vimeo.*+json;version=3.4" into authHeader
   put CR & "Authorization: Bearer" && authToken after authHeader
   set the httpheaders to authHeader
end _VimeoSetAuthHeaders


--> Deps
-
function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get
