script "lib_DisplayYoutube"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayYoutube
type: library
version: 0.1

/*
A library to display interactions with Youtube.
*/


--> Working on
-


--> Install | Youtube
-
command terminal_YoutubeDownload youTubeUrl, pFormat, pDownloadMetadata, pBestMP4 
   put youtube_ConstructDownloadShell (youTubeUrl, pFormat, pDownloadMetadata, pBestMP4) into someShell
   terminal_PasteScript someShell
end terminal_YoutubeDownload

command install_YoutubeDl pUseTerminal
   put "brew install youtube-dl" into shellScript
   if pUseTerminal is not false then
      terminal_PasteScript shellScript
      return the result
   else
      put shell (shellScript) into shellResult
      return shellResult
   end if
end install_YoutubeDl


--> Launch | Youtube
-
command launch_YoutubeDownloadDocumentation
   launch url "https://github.com/yt-dlp/yt-dlp/wiki"
   launch url "https://github.com/ytdl-org/youtube-dl"
end launch_YoutubeDownloadDocumentation


--> Display | Video
-
command display_Video mFile, pDisplayView, pStackLabel, pStackStyle, pStackRect
   -- mplayer_Play mFile
   -- display_View "View|Movie", mFile, pStackLabel, pStackRect, "movie_File", pStackStyle
   if pStackLabel is empty then put "Video" into pStackLabel
   
   display_ModuleInstance "View|Movie", mFile, pStackLabel, pDisplayView, "movie_File", pStackStyle
   put the result into dView  
   return dView
end display_Video


--> Display | Youtube
-
command display_YoutTubeChannels
   put youtube_ListMyChannels() into ytData
   display_Data ytData, "My Channels", "Youtube"
end display_YoutTubeChannels

command display_YoutTubePlaylists
   put youtube_ListMyPlaylists() into ytData
   display_Data ytData, "My Playlists", "Youtube"
end display_YoutTubePlaylists

command display_YoutubeVideoData videoID, pNextPageToken
   if videoID is empty then put "Qav6joFjKw0" into videoID
   --
   put youtube_FetchVideoArray (videoID) into videoData
   --
   display_Data videoData, videoID, "Youtube"
   put the result into displayView
   return displayView
end display_YoutubeVideoData
