script "lib_YoutubeDownload"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_YoutubeDownload
type: library
version: 0.1

/*

*/


--> Variables
-
constant YTdlCommand = "yt-dlp"
-- constant YTdlCommand = "youtube-dl"


--> Working on
-

--> YouTube | Download
-
command youtube_DownloadVideo youTubeUrl, pDownloadMetadata, pBestMP4
   set the cursor to watch
   put youtube_ConstructDownloadShell (youTubeUrl, pDownloadMetadata, pBestMP4) into someShell
   put shell (someShell) into shellResult
   --
   put youtube_DownloadParseShellResult (shellResult) into shortDownloadedFile
   return shortDownloadedFile
end youtube_DownloadVideo

function youtube_ListFormats youTubeUrl
   put youtube_FetchFormatArray (youTubeUrl) into fArray
   put the keys of fArray into availableFormats
   return availableFormats
end youtube_ListFormats

function youtube_ConstructDownloadShell youtubeVideoURL, pDownloadMetadata, pBestMP4
   put YTdlCommand into someShell
   --
   if pDownloadMetadata is true then
      put space & "--write-description" after someShell
      put space & "--write-info-json" after someShell
      put space & "--write-annotations" after someShell
      put space & "--write-sub" after someShell
      put space & "--write-thumbnail" after someShell
   end if
   --
   switch pBestMP4
      case "apple"
      case "h264"
         -- `bestvideo[vcodec=avc1]`: This selects the best quality video stream that uses the H.264 codec (represented by `avc1` in `youtube-dl`).
         -- `bestaudio[ext=m4a]`: This selects the best quality audio stream in M4A format, which is AAC audio.
         -- `/mp4`: If the combined best video and audio streams aren't available in MP4 format, it will default to downloading the best quality MP4.
         
         put space & "-f 'bestvideo[vcodec=avc1]+bestaudio[ext=m4a]/mp4'" after someShell
         break
      case "mp4"
         -- Download best mp4 format available or any other best if no mp4 available
         put space & "-f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'" after someShell
         break
      case empty
         -- best quality
         break
      default
         -- ie mp4,best,ogg
         put space & "-f" && pBestMP4 after someShell
   end switch
   --
   put space & kwote (youtubeVideoURL) after someShell
   return someShell
end youtube_ConstructDownloadShell

function youtube_DownloadParseShellResult shellResult
   /*
   [youtube] ns-qtoxnAS8: Downloading webpage
   [youtube] ns-qtoxnAS8: Downloading video info webpage
   [youtube] ns-qtoxnAS8: Extracting video information
   [youtube] ns-qtoxnAS8: Searching for annotations.
   [youtube] ns-qtoxnAS8: Downloading MPD manifest
   [info] Writing video description to: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.description
   [info] Writing video annotations to: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.annotations.xml
   [info] Writing video description metadata as JSON to: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.info.json
   [download] Destination: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.mp4
   [download]   0.0% of 33.43MiB at Unknown speed ETA Unknown ETA
   [download]   0.0% of 33.43MiB at 138.07KiB/s ETA 04:08
   [download]   0.0% of 33.43MiB at 316.21KiB/s ETA 
   */
   
   -- [download] Destination: Paddy's Lamentation - Gangs of New York (6_12) Movie CLIP (2002) HD-ns-qtoxnAS8.mp4
   set the wholematches to false
   put lineoffset ("[download] Destination: ", shellResult) into lineNum
   put line lineNum of shellResult into downloadLine
   set the itemdelimiter to ":"
   delete item 1 of downloadLine
   put word 1 to -1 of downloadLine into shortDownloadedFile
   --
   return shortDownloadedFile
end youtube_DownloadParseShellResult

function youtube_FetchFormatArray youTubeUrl
   put YTdlCommand && "-F" into someShell
   put space & youTubeUrl after someShell
   --
   put shell (someShell) into shellResult
   put word - 1 of line 2 of shellResult into videoID
   --
   repeat with lineNum = 4 to the number of lines of shellResult
      get line lineNum of shellResult
      --
      put word 1 of it into fCode
      put word 2 of it into fWord
      --
      put word 3 to -1 of item 1 of it into fText
      put item 2 of it into someFormat
      put item 3 of it into fSize
      --
      put fText into fArray [fWord][fCode]["fText"]
      put fSize into fArray [fWord][fCode]["size"]
      put someFormat into fArray [fWord][fCode]["format"]
   end repeat
   return fArray
end youtube_FetchFormatArray
