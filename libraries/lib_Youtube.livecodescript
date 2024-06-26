﻿script "lib_Youtube"
--> MetaData
-
name: lib_Youtube
type: script library
license: GPLv3
copyright: David Bovill
deps: lib_Fedwiki
version: 0.6

/*
A library for the Youtube API.
*/

--> Variables
-
constant YoutubeRestStem = "https://youtube.googleapis.com/youtube/v3/"
local LocalArray


--> Move
-
function vimeo_ConstructWatchUrl videoID
   put "https://vimeo.com/" & videoID into vimeoURL
   return vimeoURL
end vimeo_ConstructWatchUrl


--> Working on
-
function youtube_FetchUserChannelJson userName
   -- GET https://www.googleapis.com/youtube/v3/channels?part=id&forUsername=WorldCryptoNetwork&key={YOUR_API_KEY}
   put "channels?" into channelBit
   put "part=id&forUsername=" & urlencode (userName) after channelBit
   put _FetchYoutubeJSON (channelBit) into someJSON
   return someJSON
end youtube_FetchUserChannelJson

function youtube_FetchPlayListJson playlistID, pMaxResults, pNextPageToken
   if pMaxResults is empty then put 50 into pMaxResults
   
   put "playlistItems?part=snippet&playlistId=" & playlistID into channelBit
   if pNextPageToken is not empty then
      put "&pageToken=" & pNextPageToken after channelBit
   end if
   put "&maxResults=" & pMaxResults after channelBit
   put _FetchYoutubeJSON (apiBit) into someJSON
   return someJSON
end youtube_FetchPlayListJson

function youtube_ListMyChannels
   /*
   GET /youtube/v3/channels?part=snippet&mine=true HTTP/1.1
   Host: www.googleapis.com
   Authorization: Bearer access_token
   */
   
   put "channels?part=snippet&mine=true" into apiBit
   put _FetchYoutubeData (apiBit, true) into ytData
   return ytData
end youtube_ListMyChannels

function youtube_ListMyPlaylists
   /* curl \
   'https://youtube.googleapis.com/youtube/v3/playlists?part=snippet%2CcontentDetails&maxResults=25&mine=true&key=[YOUR_API_KEY]' \
   --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
   --header 'Accept: application/json' \
   --compressed
   */
   
   put "playlists?part=snippet%2CcontentDetails&maxResults=25&mine=true" into apiBit
   put _FetchYoutubeData (apiBit, true) into ytData
   return ytData
end youtube_ListMyPlaylists


--> Youtube | REST
-
command youtube_Authenticate
   /*
   https://accounts.google.com/o/oauth2/v2/auth?
   scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fyoutube.readonly&
   response_type=code&
   state=security_token%3D138r5719ru3e1%26url%3Dhttps%3A%2F%2Foauth2.example.com%2Ftoken&
   redirect_uri=http%3A//127.0.0.1%3A9004&
   client_id=client_id
   */
   
   constant kAuthURL = "https://accounts.google.com/o/oauth2/v2/auth" -- "https://oauth2.googleapis.com"
   constant kTokenURL = "https://oauth2.googleapis.com/token"
   --
   put "https://www.googleapis.com/auth/youtube.readonly" into kScopes
   
   put youtube_GetClientID() into clientID
   put youtube_GetClientSecret() into clientSecret
   --
   OAuth2 kAuthURL, kTokenURL, clientID, clientSecret, kScopes, 54303
   if the result is not empty then
      return "Not authorized!"
   else
      put it into authArray
      return authArray
   end if
end youtube_Authenticate

function youtube_GetAccessToken
   return LocalArray ["Youtube accessToken"]
end youtube_GetAccessToken

command youtube_SetAccessToken accessToken
   put accessToken into LocalArray ["Youtube accessToken"]
end youtube_SetAccessToken

function youtube_GetApiKey
   put secret_Get ("YoutubeApiKey", "youtube") into apiKey
   return apiKey
end youtube_GetApiKey

command youtube_SetApiKey apiKey
   secret_Set "YoutubeApiKey", apiKey, "youtube"
   put the result into modelDataFile
   return modelDataFile
end youtube_SetApiKey

function youtube_GetClientID
   put secret_Get ("Youtube_ClientID", "youtube") into clientID
   return clientID
end youtube_GetClientID

command youtube_SetClientID clientID
   secret_Set "Youtube_ClientID", clientID, "youtube"
   put the result into modelDataFile
   return modelDataFile
end youtube_SetClientID

function youtube_GetClientSecret
   put secret_Get ("Youtube_ClientSecret", "youtube") into clientSecret
   return clientSecret
end youtube_GetClientSecret

command youtube_SetClientSecret clientSecret
   secret_Set "Youtube_ClientSecret", clientSecret, "youtube"
   put the result into modelDataFile
   return modelDataFile
end youtube_SetClientSecret


--> Youtube
-
function youtube_ConstructWatchUrl videoID
   put "https://www.youtube.com/watch?v=" & videoID into youtubeURL
   return youtubeURL
end youtube_ConstructWatchUrl

function youtube_GetVideoID someURL
   set the itemdelimiter to "/"
   put item 3 of someURL into youtubeBit
   put item 4 of someURL into firstPathBit
   
   if youtubeBit ends with "youtube.com" is false then
      put "Not a link that I can parse:" && droppedURL into errorText
      return "error," && errorText
   end if
   
   set the itemdelimiter to "?"
   delete item 1 of firstPathBit
   --
   split firstPathBit with "&" and "="
   put firstPathBit ["v"] into videoID
   --
   return videoID
end youtube_GetVideoID

function youtube_HtmlEmbed videoID, pNextPageToken
   put youtube_FetchVideoArray (videoID, pNextPageToken) into videoData
   put videoData ["items"][1]["player"]["embedHtml"] into embedHTML
   return embedHTML
end youtube_HtmlEmbed

function youtube_FetchVideoArray videoID, pNextPageToken
   put "videos?" into channelBit
   put "part=snippet,player,contentDetails" & "&" after channelBit
   put "id=" & videoID & "&" after channelBit
   if pNextPageToken is not empty then
      put "pageToken=" & pNextPageToken & "&" after channelBit
   end if
   delete char -1 of channelBit
   --
   put _FetchYoutubeData (channelBit) into videoArray
   return videoArray
end youtube_FetchVideoArray


--> Youtube | Playlist | Index
-
function youtube_FetchPlayListIndexPageJson playlistID, pPageTitle, pDirection, pNumbered, pDroppedURL
   put youtube_FetchPlayListIndexPageArray (playlistID, pPageTitle, pDirection, pNumbered, pDroppedURL) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchPlayListIndexPageJson

function youtube_FetchPlayListIndexPageArray playlistID, pPageTitle, pDirection, pNumbered, pDroppedURL
   set_PlayListPageTitle pPageTitle, playlistID
   put youtube_FetchAllPlayListArray (playlistID) into orderedSnippetArray
   put construct_VideoIndexPageArray (orderedSnippetArray, pPageTitle, pDirection, pNumbered, pDroppedURL) into pageArray
   return pageArray
end youtube_FetchPlayListIndexPageArray


--> Youtube | Channel | Index
-
function youtube_FetchChannelIndexPageJson channelID
   put youtube_FetchChannelIndexPageArray (channelID) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchChannelIndexPageJson

function youtube_FetchChannelIndexPageArray channelID, pDroppedURL
   -- here the numbers of those found and indicated are all a bit different.
   -- probably a bug in the paging
   
   put youtube_FetchAllSearchChannelArray (channelID) into allSearchChannelArray
   -- put youtube_FetchSearchChannelArray (channelID) into searchChannelArray -- finds more items
   -- put youtube_FetchChannelUploadPlayListArray (channelID) into allUploadArray
   
   -- allSearchChannelArray is not the same structure as a playListArray (but videoTitle is OK)
   put youtube_FetchChannelArray (channelID) into channelArray   
   deconstruct_ChannelArray channelArray, channelTitle, channelDescription, thumbnailURL, uploadsPlaylistID
   put channelTitle && "Videos" into pageTitle
   put construct_VideoIndexPageArray (allSearchChannelArray, pageTitle, pDirection, pNumbered, pDroppedURL) into pageArray
   return pageArray
end youtube_FetchChannelIndexPageArray


--> Youtube | Channel | Uploads
-
function youtube_FetchChannelUploadPageJson channelID, pMaxResults, pDontLinkTitle, pNextPageToken
   put youtube_FetchChannelUploadPageArray (channelID, pMaxResults, pDontLinkTitle, pNextPageToken) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchChannelUploadPageJson

function youtube_FetchChannelUploadPlayListArray channelID
   put youtube_FetchChannelArray (channelID) into channelArray   
   deconstruct_ChannelArray channelArray, channelTitle, channelDescription, thumbnailURL, uploadsPlaylistID   
   put youtube_FetchAllPlayListArray (uploadsPlaylistID) into orderedSnippetArray
   -- put youtube_FetchPlayListArray (uploadsPlaylistID, pMaxResults, pNextPageToken) into playlistArray
   return orderedSnippetArray
end youtube_FetchChannelUploadPlayListArray

function youtube_FetchChannelUploadPageArray channelID, pMaxResults, pDontLinkTitle, pNextPageToken
   put youtube_FetchChannelArray (channelID) into channelArray   
   deconstruct_ChannelArray channelArray, channelTitle, channelDescription, thumbnailURL, uploadsPlaylistID
   put channelTitle && "Videos" into pageTitle
   put youtube_FetchPlayListPageArray (uploadsPlaylistID, pageTitle, pMaxResults, pDontLinkTitle, pNextPageToken) into pageArray
   return pageArray
end youtube_FetchChannelUploadPageArray


--> Youtube | User | Uploads
-
function youtube_FetchUserUploadPageJson userName, pMaxResults, pDontLinkTitle
   put youtube_FetchUserUploadPageArray (userName, pMaxResults, pDontLinkTitle) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchUserUploadPageJson

function youtube_FetchUserUploadPageArray userName, pMaxResults, pDontLinkTitle
   put youtube_FetchUserChannelID (userName) into channelID
   put youtube_FetchChannelUploadPageArray (channelID, pMaxResults, pDontLinkTitle) into pageArray
   return pageArray
end youtube_FetchUserUploadPageArray


--> Youtube | ThumbNails
-
function youtube_FetchVideoThumbPageJSON videoID, pPageTitle, pNextPageToken, pDontLinkTitle
   put youtube_FetchVideoThumbPageArray (videoID, pPageTitle, pNextPageToken, pDontLinkTitle) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchVideoThumbPageJSON

function youtube_FetchVideoThumbPageArray videoID, pPageTitle, pNextPageToken, pDontLinkTitle, pSourceArray
   put youtube_FetchVideoSnippetArray (videoID, pNextPageToken) into snippetArray
   put convert_SnippetToThumbPageArray (snippetArray, videoID, pPageTitle, pDontLinkTitle, pSourceArray) into pageArray
   return pageArray
end youtube_FetchVideoThumbPageArray


--> Youtube | Playlists
-
function youtube_FetchVideoPageJSON videoID, pPageTitle, pNextPageToken, pDontLinkTitle
   put youtube_FetchVideoPageArray (videoID, pPageTitle, pNextPageToken, pDontLinkTitle) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchVideoPageJSON

function youtube_FetchVideoPageArray videoID, pPageTitle, pNextPageToken, pDontLinkTitle, pSourceArray
   put youtube_FetchVideoSnippetArray (videoID, pNextPageToken) into snippetArray
   put convert_SnippetToPageArray (snippetArray, videoID, pPageTitle, pDontLinkTitle, pSourceArray) into pageArray
   return pageArray
end youtube_FetchVideoPageArray

function youtube_FetchVideoSnippetArray videoID, pNextPageToken
   put youtube_FetchVideoArray (videoID, pNextPageToken) into videoArray
   put videoArray ["items"][1]["snippet"] into snippetArray
   return snippetArray
end youtube_FetchVideoSnippetArray


--> Youtube | Playlist | All
-
function youtube_FetchAllUserUploadPageJson userName, pDontLinkTitle
   put youtube_FetchAllUserUploadPageArray (userName, pDontLinkTitle) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchAllUserUploadPageJson

function youtube_FetchAllUserUploadPageArray userName, pDontLinkTitle
   put youtube_FetchUserChannelID (userName) into channelID
   put youtube_FetchAllChannelUploadPageArray (channelID, pDontLinkTitle) into pageArray
   return pageArray
end youtube_FetchAllUserUploadPageArray

function youtube_FetchAllChannelUploadPageJson channelID, pDontLinkTitle
   put youtube_FetchAllChannelUploadPageArray (channelID, pDontLinkTitle) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchAllChannelUploadPageJson

function youtube_FetchAllChannelUploadPageArray channelID, pDontLinkTitle
   put youtube_FetchChannelArray (channelID) into channelArray   
   deconstruct_ChannelArray channelArray, channelTitle, channelDescription, thumbnailURL, uploadsPlaylistID
   put channelTitle && "Videos" into pageTitle
   put youtube_FetchAllPlayListPageArray (uploadsPlaylistID, pageTitle, pDontLinkTitle) into pageArray
   return pageArray
end youtube_FetchAllChannelUploadPageArray

function youtube_FetchAllPlayListPageJson playlistID, pPageTitle, pDontLinkTitle
   put youtube_FetchAllPlayListPageArray (playlistID, pPageTitle, pDontLinkTitle) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchAllPlayListPageJson

function youtube_FetchAllPlayListPageArray playlistID, pPageTitle, pDontLinkTitle
   set_PlayListPageTitle pPageTitle, playlistID
   put youtube_FetchAllPlayListArray (playlistID) into orderedSnippetArray
   put construct_AllVideoPageArray (orderedSnippetArray, pPageTitle, empty, pDontLinkTitle) into pageArray
   return pageArray
end youtube_FetchAllPlayListPageArray

function youtube_FetchAllPlayListArray playlistID
   local nextPageToken, orderedSnippetArray
   repeat
      put youtube_FetchPlayListArray (playlistID, 50, nextPageToken) into nextPlaylistArray
      put nextPlaylistArray ["nextPageToken"] into nextPageToken
      if nextPageToken is empty then
         add_PlayListArrayToOrderedSnippetArray orderedSnippetArray, nextPlaylistArray -- last or first and only item
         exit repeat
      else
         add_PlayListArrayToOrderedSnippetArray orderedSnippetArray, nextPlaylistArray
      end if
   end repeat
   return orderedSnippetArray
end youtube_FetchAllPlayListArray

function youtube_FetchAllSearchChannelArray channelID, pSearchQuery
   local nextPageToken, orderedSnippetArray
   repeat
      put youtube_FetchSearchChannelArray (channelID, pSearchQuery, 50, nextPageToken) into nextPlaylistArray
      put nextPlaylistArray ["nextPageToken"] into nextPageToken
      if nextPageToken is empty then
         add_SearchArrayToOrderedSnippetArray orderedSnippetArray, nextPlaylistArray -- last or first and only item
         exit repeat
      else
         add_SearchArrayToOrderedSnippetArray orderedSnippetArray, nextPlaylistArray
      end if
   end repeat
   return orderedSnippetArray
end youtube_FetchAllSearchChannelArray


--> Youtube | Playlist
-
function youtube_FetchPlayListPageJson playlistID, pPageTitle, pMaxResults, pDontLinkTitle, pNextPageToken
   put youtube_FetchPlayListPageArray (playlistID, pPageTitle, pMaxResults, pDontLinkTitle, pNextPageToken) into pageArray
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end youtube_FetchPlayListPageJson

function youtube_FetchPlayListPageArray playlistID, pPageTitle, pMaxResults, pDontLinkTitle, pNextPageToken
   local orderedSnippetArray
   set_PlayListPageTitle pPageTitle, playlistID
   
   put youtube_FetchPlayListArray (playlistID, pMaxResults, pNextPageToken) into playlistArray
   put playlistArray ["nextPageToken"] into nextPageToken
   put playlistArray ["prevPageToken"] into prevPageToken
   
   put playlistArray ["items"] into orderedSnippetArray
   put construct_AllVideoPageArray (orderedSnippetArray, pPageTitle, nextPageToken, pDontLinkTitle) into pageArray
   return pageArray
end youtube_FetchPlayListPageArray

function youtube_FetchPlayListArray playlistID, pMaxResults, pNextPageToken
   if pMaxResults is empty then put 50 into pMaxResults
   
   put "playlistItems?part=snippet&playlistId=" & playlistID into channelBit
   if pNextPageToken is not empty then
      put "&pageToken=" & pNextPageToken after channelBit
   end if
   put "&maxResults=" & pMaxResults after channelBit
   put _FetchYoutubeData (channelBit) into someArray
   return someArray
end youtube_FetchPlayListArray

function youtube_FetchPlayListInfoArray playlistID
   -- GET https://www.googleapis.com/youtube/v3/playlists?part=snippet&id=UUR9gdpWisRwnk_k23GsHfcA&key={YOUR_API_KEY}
   put "playlists?part=snippet&id=" & playlistID into channelBit
   put _FetchYoutubeData (channelBit) into someArray
   return someArray
end youtube_FetchPlayListInfoArray


--> Youtube | Channels | Search
-
function youtube_FetchSearchChannelArray channelID, pSearchQuery, pMaxResults, pNextPageToken
   -- GET https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCR9gdpWisRwnk_k23GsHfcA&maxResults=50&key={YOUR_API_KEY}
   if pMaxResults is empty then put 50 into pMaxResults
   --
   put "search?part=snippet&channelId=" & channelID into channelBit
   put "&maxResults=" & pMaxResults after channelBit
   if pNextPageToken is not empty then
      put "&pageToken=" & pNextPageToken after channelBit
   end if
   if pSearchQuery is not empty then
      put "&q=" & urlencode (pSearchQuery) after channelBit
   end if
   put _FetchYoutubeData (channelBit) into someArray
   return someArray
end youtube_FetchSearchChannelArray

function youtube_FetchSearchChannelJson channelID, pSearchQuery, pMaxResults, pNextPageToken
     return someJSON
end youtube_FetchSearchChannelJson


--> Youtube | Channels
-
function youtube_FetchChannelArray channelID
   -- GET https://www.googleapis.com/youtube/v3/channels?part=contentDetails&id=UCR9gdpWisRwnk_k23GsHfcA&key={YOUR_API_KEY}
   put "contentDetails" into somePart
   put urlencode(comma) & "snippet" after somePart
   --
   put "channels?" into channelBit
   put "part=" & somePart after channelBit
   put "&id=" & channelID after channelBit
   put _FetchYoutubeData (channelBit) into someArray
   --
   return someArray
end youtube_FetchChannelArray

function youtube_FetchChannelUploadsPlayListID channelID
   put youtube_FetchChannelArray (channelID) into channelArray   
   deconstruct_ChannelArray channelArray, channelTitle, channelDescription, thumbnailURL, uploadsPlaylistID
   return uploadsPlaylistID
end youtube_FetchChannelUploadsPlayListID

function youtube_FetchUserChannelID userName
   put "channels?" into channelBit
   put "part=id&forUsername=" & urlencode (userName) after channelBit
   put _FetchYoutubeData (channelBit) into someArray
   --
   put someArray ["items"][1]["id"] into channelID
   return channelID
end youtube_FetchUserChannelID


--> Youtube | Search
-
function youtube_FindChannelID searchChannelSlug
   put youtube_FindChannelArray (searchChannelSlug) into snippetArray
   -- display_Array snippetArray, searchChannelSlug
   put snippetArray ["channelId"] into channelID
   return channelID
end youtube_FindChannelID

function youtube_FindChannelArray searchChannelSlug
   put youtube_FetchSearchArray (searchChannelSlug) into searchArray
   put searchArray ["items"] into itemArray
   repeat for each key itemNum in itemArray
      put itemArray [itemNum]["snippet"] into snippetArray
      put snippetArray ["channelTitle"] into foundChannelSlug
      put snippetArray ["title"] into someTitle
      if foundChannelSlug is empty then
         put someTitle into foundChannelSlug
      end if
      if foundChannelSlug = searchChannelSlug then
         return snippetArray
      end if
   end repeat
   return empty
end youtube_FindChannelArray

function youtube_FetchSearchArray channelTitle
   -- https://www.googleapis.com/youtube/v3/search?part=snippet&q=WorldCryptoNetwork&type=channel&key={YOUR_API_KEY}
   put "search?part=snippet&q=" & urlencode (channelTitle) & "&type=channel" into channelBit
   put "&maxResults=50" after channelBit
   put _FetchYoutubeData (channelBit) into someData
   return someData
end youtube_FetchSearchArray


--> Private
-
private function _FetchYoutubeJSON apiBit, pAddApiKey
   put _ConstructRestUrl(apiBit) into restUrl
   if pAddApiKey is not false then
      -- not sure this is ever needed?
      put "&key=" & youTube_GetApiKey() after restUrl
   end if
   --
   put youtube_GetAccessToken() into accessToken
   --
   put youtube_GetAccessToken() into accessToken
   put jsonrpc_GET (restURL, accessToken) into someJSON
   return someJSON
end _FetchYoutubeJSON

private function _FetchYoutubeData apiBit, pAddApiKey
   put _ConstructRestUrl(apiBit) into restUrl
   if pAddApiKey is not false then
      -- not sure this is ever needed?
      put "&key=" & youTube_GetApiKey() after restUrl
   end if
   --
   put youtube_GetAccessToken() into accessToken
   put jsonrpc_GetArray (restURL, accessToken) into ytData
   return ytData
end _FetchYoutubeData

private function _ConstructRestUrl apiBit
   put YoutubeRestStem & apiBit into restUrl
   return restUrl
end _ConstructRestUrl

private command set_PlayListPageTitle @pageTitle, playlistID
   if pageTitle is empty then
      put youtube_FetchPlayListInfoArray (playlistID) into infoArray
      deconstruct_PlayListInfoArray infoArray, playListTitle, thumbnailURL, playListDescription
      put playListTitle into pageTitle
   end if
end set_PlayListPageTitle

private function convert_SnippetToThumbPageArray snippetArray, pVideoID, pPageTitle, pDontLinkTitle, pSourceArray
   local pageArray
   add_SnippetToThumbPageArray pageArray, snippetArray, pVideoID, true, pDontLinkTitle
   put the result into videoTitle
   
   if pPageTitle is empty then put videoTitle into pPageTitle
   put pPageTitle into pageArray ["title"]
   put journalArray_Construct (pageTitle, pSourceArray) into pageArray ["journal"]  -- strip journal to minimum
   return pageArray
end convert_SnippetToThumbPageArray

private function convert_SnippetToPageArray snippetArray, pVideoID, pPageTitle, pDontLinkTitle, pSourceArray
   local pageArray
   add_SnippetToPageArray pageArray, snippetArray, pVideoID, true, pDontLinkTitle
   put the result into videoTitle
   
   if pPageTitle is empty then put videoTitle into pPageTitle
   put pPageTitle into pageArray ["title"]
   put journalArray_Construct (pageTitle, pSourceArray) into pageArray ["journal"]  -- strip journal to minimum
   return pageArray
end convert_SnippetToPageArray

private command deconstruct_PlayListInfoArray infoArray, @playListTitle, @thumbnailURL, @playListDescription
   put infoArray ["items"][1]["snippet"] into snippetArray
   put snippetArray ["channelId"] into channelID
   put snippetArray ["channelTitle"] into channelTitle
   
   put snippetArray ["title"] into playListTitle
   put snippetArray ["description"] into playListDescription
   put snippetArray ["publishedAt"] into publishedAt
   put snippetArray ["thumbails"] into thumbailsArray
   put thumbailsArray ["medium"]["url"]  into thumbnailURL
   return thumbailsArray
end deconstruct_PlayListInfoArray

private function construct_VideoIndexPageArray orderedSnippetArray, pageTitle, pDirection, pNumbered, pDroppedURL
   put pageTitle into pageArray ["title"]
   --
   put "To import the videos interact with out little sacraficial lambs!" into someHelp
   put space & "Create your video archive page (you can edit the links for tidier titles if you want)." after someHelp
   put space & "And then drag the sacrifical lamb to your new page." after someHelp
   put CR & CR after someHelp
   put "Once you have created you page, drag and drop the stand-alone link at the bottom of the page onto the transporter." after someHelp
   pageArray_AddText pageArray, someHelp
   --
   put "Here is and index of videos from the playlist" && quote & pageTitle & quote & ":" into firstParagraph
   pageArray_AddText pageArray, firstParagraph
   --
   construct_HtmlIndexArrays orderedSnippetArray, htmlIndex, lookupArray, pDirection, pNumbered
   pageArray_AddHtml pageArray, htmlIndex
   
   -- construct_MarkdownArrays orderedSnippetArray, markdownLinkIndex, lookupArray, pDirection
   -- pageArray_AddMarkdown pageArray, markdownLinkIndex
   
   -- construct sourceArray
   put "https://livecode.world/youtube/transportAgain" into transportURL
   put the milliseconds into dateTransported
   put "https://github.com/LiveCodeWorld/youtube.lc" into repoURL
   put fedwiki_ConstructCreateSourceArray (transportURL, pDroppedURL, dateTransported, repoURL) into sourceArray
   put lookUpArray into sourceArray ["link_dictionary"]
   
   put journalArray_Construct (pageTitle, sourceArray) into pageArray ["journal"]  -- strip journal to minimum
   return pageArray
end construct_VideoIndexPageArray

private function construct_HtmlIndex orderedSnippetArray, pDirection, pNumbered
   construct_HtmlIndexArrays orderedSnippetArray, htmlIndex, lookupArray, pDirection, pNumbered
   return htmlIndex
end construct_HtmlIndex

private command construct_HtmlIndexArrays orderedSnippetArray, @htmlIndex, @lookupArray, pDirection, pNumbered
   put item 2 of the extents of orderedSnippetArray into maxNum
   if pNumbered is false then
      put "<ul>" into htmlIndex
   else
      put "<ol>" into htmlIndex
   end if
   switch pDirection
      case "recentFirst"
         repeat with episodeNum = 1 to maxNum
            put orderedSnippetArray [episodeNum]["snippet"] into snippetArray
            deconstruct_VideoSnippetArray snippetArray, videoTitle, videoDescription, videoID, thumbNailURL, publishedAt, positionPlusOneNum, tagArray, thumbNailWidth
            put CR & "    " after htmlIndex
            put "<li>" & fedwiki_ConstructLink (videoTitle) & "</li>" after htmlIndex
            put snippetArray into lookupArray [videoTitle]
         end repeat
         break
      default -- "oldestFirst"
         repeat with episodeNum = maxNum down to 1
            put orderedSnippetArray [episodeNum]["snippet"] into snippetArray
            deconstruct_VideoSnippetArray snippetArray, videoTitle, videoDescription, videoID, thumbNailURL, publishedAt, positionPlusOneNum, tagArray, thumbNailWidth
            put CR & "    " after htmlIndex
            put "<li>" & fedwiki_ConstructLink (videoTitle) & "</li>" after htmlIndex
            put snippetArray into lookupArray [videoTitle]
         end repeat
   end switch
   put CR after htmlIndex
   if pNumbered is false then
      put "</ul>" after htmlIndex
   else
      put "</ol>" after htmlIndex
   end if
   return htmlIndex
end construct_HtmlIndexArrays

private function construct_MarkDownIndex orderedSnippetArray, pDirection
   construct_MarkdownArrays orderedSnippetArray, markdownLinkIndex, lookupArray, pDirection
   return markdownLinkIndex
end construct_MarkDownIndex

private command construct_MarkdownArrays orderedSnippetArray, @markdownLinkIndex, @lookupArray, pDirection
   put item 2 of the extents of orderedSnippetArray into maxNum
   switch pDirection
      case "recentFirst"
         repeat with episodeNum = 1 to maxNum
            put orderedSnippetArray [episodeNum]["snippet"] into snippetArray
            deconstruct_VideoSnippetArray snippetArray, videoTitle, videoDescription, videoID, thumbNailURL, publishedAt, positionPlusOneNum, tagArray, thumbNailWidth
            put "*" && fedwiki_ConstructLink (videoTitle) into videoLink
            put videoLink & CR after markdownLinkIndex
            put snippetArray into lookupArray [videoTitle]
         end repeat
         break
      default
         repeat with episodeNum = maxNum down to 1
            put orderedSnippetArray [episodeNum]["snippet"] into snippetArray
            deconstruct_VideoSnippetArray snippetArray, videoTitle, videoDescription, videoID, thumbNailURL, publishedAt, positionPlusOneNum, tagArray, thumbNailWidth
            put "*" && fedwiki_ConstructLink (videoTitle) into videoLink
            put videoLink & CR after markdownLinkIndex
            put snippetArray into lookupArray [videoTitle]
         end repeat
   end switch
   delete char -1 of markdownLinkIndex
   return markdownLinkIndex
end construct_Markdownarrays

private function construct_AllVideoPageArray orderedSnippetArray, pageTitle, pNextPageToken, pDontLinkTitle, pUseThumbs, pSourceArray
   put pageTitle into pageArray ["title"]
   
   -- add some metadata so transported pages can be found, and next paginated page authored
   put "Youtube Transport" into pageArray ["metadata"]["author"]
   if pNextPageToken is not empty then put pNextPageToken into pageArray ["metadata"]["nextPageToken"]
   
   put item 2 of the extents of orderedSnippetArray into maxNum
   repeat with episodeNum = 1 to maxNum
      put orderedSnippetArray [episodeNum] into itemArray
      put itemArray ["snippet"] into snippetArray
      
      if pUseThumbs is true then
         add_SnippetToThumbPageArray pageArray, snippetArray
      else
         add_SnippetToPageArray pageArray, snippetArray, empty, false, pDontLinkTitle
      end if
      put the result into videoTitle
   end repeat
   put journalArray_Construct (pageTitle, pSourceArray) into pageArray ["journal"]  -- strip journal to minimum
   return pageArray
end construct_AllVideoPageArray

private command add_SnippetToThumbPageArray @pageArray, snippetArray, pVideoID
   deconstruct_VideoSnippetArray snippetArray, videoTitle, videoDescription, videoID, thumbNailURL, publishedAt, episodeNum, tagArray, thumbNailWidth
   if pVideoID is not empty then put pVideoID into videoID
   put word 1 to 3 of item 2 of publishedAt into publishedAt  -- from internet date
   
   put youtube_ConstructWatchUrl (videoID) into youtubeURL
   
   -- put "100%" into thumbNailWidth
   thumbnail_SetSmall snippetArray, thumbNailURL, thumbNailWidth
   
   put fedwiki_ConstructLink (videoTitle) & ". Broadcast on" && publishedAt & "." into videoCaption 
   put fedwiki_ConstructImageHtml (thumbNailURL, videoCaption, youtubeURL, "- youtube", thumbNailWidth) into imageHTML 
   pageArray_AddHtml pageArray, imageHTML
   
   return videoTitle
end add_SnippetToThumbPageArray

private command add_SnippetToPageArray @pageArray, snippetArray, pVideoID, pDontAddSnippetTitle, pDontLinkTitle
   local lastParagraphs
   
   deconstruct_VideoSnippetArray snippetArray, videoTitle, videoDescription, videoID, thumbNailURL, publishedAt, episodeNum, tagArray, thumbNailWidth
   if pVideoID is not empty then put pVideoID into videoID
   put word 1 to 3 of item 2 of publishedAt into publishedAt  -- from internet date
   
   if pDontAddSnippetTitle is not true then pageArray_AddMarkdown pageArray, ("#" && videoTitle)
   if videoDescription is not empty then
      put word 1 to -1 of videoDescription into videoDescription
      put line 1 of videoDescription into firstParagraph
      put line 2 to -1 of videoDescription into lastParagraphs
      pageArray_AddText pageArray, firstParagraph
   end if
   
   if pDontLinkTitle is true then
      put videoTitle & ". Broadcast on" && publishedAt & "." into videoCaption 
   else
      put fedwiki_ConstructLink (videoTitle) & ". Broadcast on" && publishedAt & "." into videoCaption 
   end if
   pageArray_AddVideo pageArray, videoID, "YOUTUBE", videoCaption
   
   if lastParagraphs is not empty then
      -- could split into individual paragraphs
      pageArray_AddText pageArray, lastParagraphs
   end if
   
   repeat for each key tagNum in tagArray
      put tagArray [tagNum] into someTag
      put "[[" & someTag & "]], " after tagList
   end repeat
   delete char -2 to -1 of tagList
   if tagList is not empty then
      pageArray_AddMarkdown pageArray, "# Tags"
      pageArray_AddText pageArray, tagList
   end if
   return videoTitle
end add_SnippetToPageArray

private command add_SearchArrayToOrderedSnippetArray @orderedSnippetArray, nextPlaylistArray
   /*
   There is not position in this array
   And the videoID is somewhere odd.  
   */
   
   put nextPlaylistArray ["items"] into someArray
   put item 2 of the extents of orderedSnippetArray into lastMaxNum
   if orderedSnippetArray is not an array then
      put someArray into orderedSnippetArray
      return lastMaxNum
   end if
   
   repeat for each key itemNum in someArray
      put someArray [itemNum] into itemArray
      
      put itemArray ["id"]["videoId"] into videoID
      
      put itemArray ["snippet"] into snippetArray
      
      put lastMaxNum + itemNum into orderedNum
      put itemArray into orderedSnippetArray [orderedNum]
   end repeat
   return lastMaxNum
end add_SearchArrayToOrderedSnippetArray

private command add_PlayListArrayToOrderedSnippetArray @orderedSnippetArray, nextPlaylistArray
   -- nextPlaylistArray is ordered in any case - but always 1-50
   put nextPlaylistArray ["items"] into someArray
   repeat for each key itemNum in someArray
      put someArray [itemNum] into itemArray
      put itemArray ["snippet"] into snippetArray
      put snippetArray ["position"] into playListNum
      add 1 to playListNum -- as "position" is zero-based
      
      put itemArray into orderedSnippetArray [playListNum]
   end repeat
end add_PlayListArrayToOrderedSnippetArray

private command deconstruct_ChannelArray channelArray, @channelTitle, @channelDescription, @thumbnailURL, @uploadsPlaylistID
   put channelArray ["items"][1] into itemArray
   put itemArray ["snippet"] into snippetArray
   put snippetArray ["title"] into channelTitle
   put snippetArray ["description"] into channelDescription
   put snippetArray ["thumbnails"]["medium"]["url"] into thumbnailURL
   put itemArray ["contentDetails"]["relatedPlayLists"] into relatedPlayListArray
   put relatedPlayListArray ["uploads"] into uploadsPlaylistID
end deconstruct_ChannelArray

private command deconstruct_VideoSnippetArray snippetArray, @videoTitle, @videoDescription,@videoID, @thumbNailURL, @publishedAt, @episodeNum, @tagArray, @thumbNailWidth
   put snippetArray ["title"] into videoTitle
   put snippetArray ["description"] into videoDescription
   put snippetArray ["tags"] into tagArray
   
   put snippetArray ["publishedAt"] into publishedAt
   date_Convert8601 publishedAt
   
   put snippetArray ["position"] into episodeNum
   add 1 to episodeNum
   
   put snippetArray ["resourceId"]["videoId"] into videoID
   
   -- thumbnail_SetMedium snippetArray, thumbNailURL, thumbNailWidth
   thumbnail_SetStandard snippetArray, thumbNailURL, thumbNailWidth
end deconstruct_VideoSnippetArray

private command thumbnail_SetStandard snippetArray, @thumbNailURL, @thumbNailWidth
   put snippetArray ["thumbnails"]["standard"] into thumbNailArray
   put thumbNailArray ["url"] into thumbNailURL
   put thumbNailArray ["width"] into thumbNailWidth
end thumbnail_SetStandard

private command thumbnail_SetMedium snippetArray, @thumbNailURL, @thumbNailWidth
   put snippetArray ["thumbnails"]["medium"] into thumbNailArray
   put thumbNailArray ["url"] into thumbNailURL
   put thumbNailArray ["width"] into thumbNailWidth
end thumbnail_SetMedium

private command thumbnail_SetSmall snippetArray, @thumbNailURL, @thumbNailWidth
   put snippetArray ["thumbnails"]["default"] into thumbNailArray
   put thumbNailArray ["url"] into thumbNailURL
   put thumbNailArray ["width"] into thumbNailWidth
end thumbnail_SetSmall


--> Deps
-
function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get

command date_Convert8601 @revisionDate
   -- converts to "internet date"
   replace "T" with return in revisionDate
   put line 1 of revisionDate into someDate
   
   put line 2 of revisionDate into someTime
   put last char of someTime into timeZoneThing
   delete last char of someTime
   
   replace "-" with comma in someDate
   
   set the itemdelimiter to "."
   put item 1 of someTime into colonTime
   put item 2 of someTime into colonSeconds
   replace ":" with comma in colonTime
   
   set the itemdelimiter to comma
   put someDate into someDateItems
   put colonTime into item 4 of someDateItems
   
   put 0 into item 7 of someDateItems
   convert someDateItems to internet date
   put someDateItems into revisionDate
end date_Convert8601
