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


--> Workign on
-
function vimeo_HtmlEmbed vimeoID
   put vimeo_FetchVideoData (vimeoID) into vimeoData
   put vimeoData ["embed"]["html"] into embedHTML
   return embedHTML
end vimeo_HtmlEmbed

function vimeo_ConstructImageFile imageURL, pImageFolder
   switch
      case pImageFolder is empty
         put the tempname into imageFolder
         break
      case there is a folder pImageFolder
         put pImageFolder into imageFolder
         break
      default
         create folder pImageFolder
         put pImageFolder into imageFolder
   end switch
   --
   set the itemdelimiter to slash
   set the linedelimiter to "?"
   put item -1 of line 1 of imageURL into shortFile
   --
   put imageFolder & slash & shortFile & ".jpg" into imageFile
   return imageFile
end vimeo_ConstructImageFile

command vimeo_DownloadThumbnail imageURL, pImageFolder
   put vimeo_ConstructImageFile (imageURL, pImageFolder) into imageFile
   put url imageURL into url ("binfile:" & imageFile)
   return imageFile
end vimeo_DownloadThumbnail


--> Vimeo | Verify
-
function vimeo_VerifyAuth
   -- GET https://api.vimeo.com/oauth/verify
   put _VimeoFetchData ("oauth/verify", true) into vimeoData
   return vimeoData
end vimeo_VerifyAuth

function vimeo_FetchVerifyAuthJson
   -- GET https://api.vimeo.com/oauth/verify
   
   put _VimeoFetchJSON ("oauth/verify", true) into vimeoJSON
   -- put _VimeoFetchJSON ("videos/229827899", true) into vimeoJSON
   return vimeoJSON
end vimeo_FetchVerifyAuthJson

function vimeo_ConstructPageArray vimeoID, pThumbQuality
   put vimeo_FetchVideoData (vimeoID) into vimeoData
   if vimeoData is not an array then return pageArray_Construct ("Error", vimeoData)
   --
   put vimeoData ["name"] into vimeoTitle
   put vimeoData ["description"] into vimeoDescription
   put vimeoData ["link"] into vimeoURL
   --
   put vimeoTitle & "." && vimeoDescription into videoDescription
   --
   put pageArray_Construct (vimeoTitle, vimeoDescription) into pageArray
   pageArray_AddVideo pageArray, vimeoID, "VIMEO", videoDescription
   --
   put vimeo_ListThumbnails (vimeoID, pThumbQuality) into thumbNailUrls
   if thumbNailUrls is not empty then
      pageArray_AddMarkDown pageArray, "# Thumbnails"
      repeat for each line thumbNailUrl in thumbNailUrls
         pageArray_AddHtmlImage pageArray, thumbNailUrl
      end repeat
   end if
   --
   return pageArray
end vimeo_ConstructPageArray


--> Vimeo | Thumbnail
-
function vimeo_FetchThumbnailData videoID
   --  https://api.vimeo.com/videos/{video_id}/pictures
   put merge ("/videos/[[videoID]]/pictures") into apiBit
   put _VimeoFetchData (apiBit, true) into vimeoData
   if vimeoData is an array then
      return vimeoData ["data"]
   else
      return vimeoData
   end if
end vimeo_FetchThumbnailData

function vimeo_ListThumbnails videoID, pThumbQuality
   if pThumbQuality is not a number then put 4 into pThumbQuality
   --
   put vimeo_FetchThumbnailData (videoID) into thumbNailData
   --
   put item 2 of the extents of thumbNailData into maxNum
   set the itemDelimiter to slash
   repeat with thumbNum = 1 to maxNum
      get thumbNailData [thumbNum]["uri"] 
      put item -1 of it into thumbID
      --
      put thumbNailData [thumbNum]["sizes"][pThumbQuality]["link"] into thumbnailURL
      --
      put thumbnailURL & CR after thumbNailUrls
   end repeat
   delete char -1 of thumbNailUrls
   --
   return thumbNailUrls
end vimeo_ListThumbnails


--> Vimeo | TitleArray
-
function vimeo_ConstructTitleArray videoData
   put videoData ["data"] into pageData
   --
   repeat with itemNum = 1 to item 2 of the extents of pageData
      put pageData [itemNum] into itemArray
      _VimeoDeconstructItemArray itemArray, videoTitle, vimeoURL, uploadStatus, description, videoURL, bigPictureURL
      --
      put description into videoTitleArray [videoTitle]["description"]
      put vimeoURL into videoTitleArray [videoTitle]["vimeoURL"]
      put videoURL into videoTitleArray [videoTitle]["videoURL"]
      put uploadStatus into videoTitleArray [videoTitle]["uploadStatus"]
      put bigPictureURL into videoTitleArray [videoTitle]["bigPictureURL"]
   end repeat
   return videoTitleArray
end vimeo_ConstructTitleArray


--> Vimeo | Videos
-
function vimeo_ListUserVideos pUserID
   -- GET/users/{user_id}/videos
   if pUserID is empty then
      put "/users/me/videos" into apiBit
   else
      put merge ("/users/[[pUserID]]/videos") into apiBit
   end if
   --
   put _VimeoFetchData (apiBit, true) into rArray
   return rArray
end vimeo_ListUserVideos

function vimeo_FetchVideoData vimeoID
   -- put vimeo_FetchVideoJSON (vimeoID) into someJSON
   -- put json_ToArray (someJSON) into vimeoData
   
   put "/videos/" & vimeoID into apiBit
   put _VimeoFetchData (apiBit, true) into vimeoData
   --
   return vimeoData
end vimeo_FetchVideoData

function vimeo_FetchVideoJSON videoID
   put "videos/" & videoID into apiBit
   put _VimeoFetchJSON (apiBit) into someJSON
   return someJSON
end vimeo_FetchVideoJSON


--> Private
-
private command _VimeoDeconstructItemArray itemArray, @videoTitle, @vimeoURL, @uploadStatus, @description, @videoURL, @bigPictureURL
   put itemArray ["name"] into videoTitle
   put itemArray ["link"] into vimeoURL
   put itemArray ["status"] into uploadStatus
   put itemArray ["description"] into description
   put itemArray ["files"][1]["link"] into videoURL
   put itemArray ["pictures"]["sizes"][1]["link"] into bigPictureURL
end _VimeoDeconstructItemArray


--> Private | REST
-
private function _VimeoFetchData apiBit, pUseAuth
   put _VimeoFetchJSON (apiBit, pUseAuth) into rJSON
   put json_ToArray (rJSON) into vimeoData
   --
   put vimeoData ["error"] into vimeoError
   if vimeoError is not empty then
      -- put vimeoData ["developer_message"] into developerMessage
      -- put vimeoData ["error_code"] into errorCode
      -- put "error," && developerMessage into someEerror
      return vimeoError
   else 
      return vimeoData
   end if
end _VimeoFetchData

private function _VimeoFetchJSON apiBit, pUseAuth
   put "https://api.vimeo.com/" & apiBit into restURL
   --
   _VimeoSetAuthHeaders pUseAuth
   put url restURL into someJSON
   return someJSON
end _VimeoFetchJSON


--> Vimeo | oAuth
-
private command _VimeoSetAuthHeaders pUseAuth
   if pUseAuth is true then
      put vimeo_GetAuthToken() into authToken
   else
      put vimeo_GetUnauthToken() into authToken
   end if
   --
   put "Accept: application/vnd.vimeo.*+json;version=3.4" into authHeader
   put CR & "Authorization: Bearer" && authToken after authHeader
   set the httpheaders to authHeader
end _VimeoSetAuthHeaders

function vimeo_GetAuthToken
   put secret_Get ("VimeoApiKey", "vimeo") into vimeoApiKey
   return vimeoApiKey
end vimeo_GetAuthToken

command vimeo_SetAuthToken accessToken
   secret_Set "VimeoApiKey", accessToken, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end vimeo_SetAuthToken


--> Vimeo | Authentication
-
private function vimeo_GetUnauthToken
   put secret_Get ("VimeoUnauthToken", "vimeo") into unauthToken
   return unauthToken
   
   
   -- old and not working 
   put _VimeoGetClientID() into clientID
   put _VimeoGetSecret() into clientSecret
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

private command vimeo_SetUnauthToken unauthToken
   secret_Set "VimeoUnauthToken", unauthToken, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end vimeo_SetUnauthToken

private function _VimeoGetClientID
   put secret_Get ("VimeoClientID", "vimeo") into vimeoApiKey
   return vimeoApiKey
end _VimeoGetClientID

private command _VimeoSetClientID clientID
   secret_Set "VimeoClientID", clientID, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end _VimeoSetClientID

private function _VimeoGetSecret
   put secret_Get ("VimeoClientSecret", "vimeo") into vimeoApiKey
   return vimeoApiKey
end _VimeoGetSecret

private command _VimeoSetSecret clientSecret
   secret_Set "VimeoClientSecret", clientSecret, "vimeo"
   put the result into modelDataFile
   return modelDataFile
end _VimeoSetSecret


--> Deps
-
function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get
