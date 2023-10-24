script "lib_DisplayYoutube"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayYoutube
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_Video mFile, pStackName, pStackStyle, pStackRect
   if pStackName is empty then put "Video" into pStackName
   -- mplayer_Play mFile
   display_View "View|Movie", mFile, pStackName, pStackRect, "movie_File", pStackStyle
   return the result
end display_Video


--> Install | Youtube
-
command terminal_YoutubeDownload youTubeUrl, pFormat, pDownloadMetadata, pBestMP$ 
   put youtube_ConstructDownloadShell (youTubeUrl, pFormat, pDownloadMetadata, pBestMP$ ) into someShell
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
