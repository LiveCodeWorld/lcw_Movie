script "lib_Melt"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_Melt
type: library
version: 0.1

/*Some help*/


--> Working on
-
command movie_SaveClip mPlayer
   put the filename of mPlayer into movieFile
   put melt_GetDisplayedArray() into mltArray
   --
   put melt_GetEntryNum (mltArray) into entryNum
   put "Clip" && (entryNum + 1) into shotcutCaption
   --
   put the clip_StartTime ["hms"] of mPlayer into inClipTime
   put the clip_EndTime ["hms"] of mPlayer into outClipTime
   --
   melt_AddPlayListEntry mltArray, inClipTime, outClipTime, movieFile, shotcutCaption
   put the result into entryNum
   --
   melt_SetDisplayedArray mltArray
   put the result into dView
   return dView
end movie_SaveClip

function movie_GetDuration movieFile, pTimeFormat
   put spotlight_GetMovieDurationInSeconds (movieFile) into durationInSeconds
   switch pTimeFormat
      case "HMS"
         put time_SecondsToHMS (durationInSeconds) into hmsDuration
         return hmsDuration
      default
         return durationInSeconds
   end switch
end movie_GetDuration

function movie_CreationDate movieFile
   put false into pConvertToUTC
   put file_CreationDate (movieFile) into creationTimeInSeconds
   put date_Construct8601 (creationTimeInSeconds, true, pConvertToUTC) into creationTime
   return creationTime
end movie_CreationDate

function melt_GetProducerNum mltArray
   put the keys of mltArray into mltKeys
   filter mltKeys with "producer"
   put the number of lines of mltKeys into producerNum
   return producerNum
end melt_GetProducerNum

function melt_GetEntryNum mltArray
   put mltArray ["mlt"]["xplaylist[1]"] into playListArray
   put the keys of playListArray into playListKeys
   filter playListKeys with "entry*"
   put the number of lines of playListKeys into entryNum
   return entryNum
end melt_GetEntryNum


--> Melt
-
function melt_GetDisplayedArray
   put melt_FindDisplayView() into dView
   put the displayed_Data of dView into mltArray
   return mltArray
end melt_GetDisplayedArray

command melt_SetDisplayedArray mltArray
   put melt_FindDisplayView() into dView
   set the displayed_Data of dView to mltArray
   return dView
end melt_SetDisplayedArray
   
function melt_FindDisplayView
   put display_FindView ("MLT", "melt_ConstructArray") into dView
   return dView
end melt_FindDisplayView

function melt_ClipLength inHMS, outHMS
   return outHMS
end melt_ClipLength

function melt_ConstructXML mltArray
   put mltArray ["mlt"]["xplaylist[1]"] into playlistArray ["playlist"]
   delete variable mltArray ["mlt"]["xplaylist[1]"]
   --
   put xml_FromArray (mltArray, empty, empty, empty, true) into mltXML
   --
   put xml_FromArray (playlistArray, empty, empty, empty, true) into playlistXML
   delete line 1 of playlistXML
   put playlistXML before line -1 of mltXML
   --
   return mltXML
end melt_ConstructXML

function melt_ConstructArray movieFile, inClipTime, outClipTime, pShotcutCaption
   _SetAttributes mltArray
   _AddProfile mltArray, 360, 480
   --
   _SetPlayListAttributes mltArray
   melt_AddPlayListEntry mltArray, inClipTime, outClipTime, movieFile, pShotcutCaption
   --
   return mltArray
end melt_ConstructArray


--> Melt
-
command melt_AddPlayListEntry @mltArray, inClipTime, outClipTime, movieFile, pShotcutCaption   
   put melt_GetEntryNum (mltArray) into entryNum
   --
   put entryNum  + 1 into newEntryNum
   put "entry" & "[" & newEntryNum & "]" into entryKey
   --
   put "producer" & entryNum into producerID
   put "producer" & "[" & newEntryNum & "]" into producerKey
   --
   put movie_GetDuration (movieFile, "HMS") into producerLength
   -- melt_AddProducer mltArray, movieFile, pShotcutCaption, inClipTime, outClipTime, pShotcutCaption, producerLength
   --   
   _SetProducerAttributes mltArray, producerKey, producerID, inClipTime, outClipTime, pShotcutCaption
   --
   _AddProducerProps mltArray, producerKey, movieFile, producerLength, pShotcutCaption
   
   --
   _AddPlayListEntry mltArray, entryKey, inClipTime, outClipTime, producerID
   --
   return entryNum
end melt_AddPlayListEntry

command melt_AddProducer @mltArray, movieFile, pShotcutCaption, pProducerInTime, pProducerOutTime, pProducerTitle, pProducerLength
   put melt_GetProducerNum (mltArray) into producerNum
   put producerNum + 1 into newProducerNum
   --
   if pShotcutCaption is empty then
      put "Clip" && newProducerNum into pShotcutCaption
   end if
   if pProducerTitle is empty then
      put "Anonymous Submission" into pProducerTitle
   end if
   if pProducerInTime is empty then
      put "00:00:00.000" into pProducerInTime
   end if
   if pProducerOutTime is empty then
      put movie_GetDuration (movieFile, "HMS") into pProducerOutTime
   end if
   if pProducerLength is empty then
      put movie_GetDuration (movieFile, "HMS") into pProducerLength
   end if
   --
   put "producer" & producerNum into producerID
   put "producer" & "[" & newProducerNum & "]" into producerKey
   --   
   _SetProducerAttributes mltArray, producerKey, producerID, pProducerInTime, pProducerOutTime, pProducerTitle
   --
   _AddProducerProps mltArray, producerKey, movieFile, pProducerLength, pShotcutCaption
   --
   return producerID
end melt_AddProducer

private command _SetProducerAttributes @mltArray, producerKey, producerID, producerInTime, producerOutTime, producerTitle
   put producerID into mltArray ["mlt"][producerKey]["@attributes"]["id"]
   put producerInTime into mltArray ["mlt"][producerKey]["@attributes"]["in"]
   put producerOutTime into mltArray ["mlt"][producerKey]["@attributes"]["out"]
   put producerTitle into mltArray ["mlt"][producerKey]["@attributes"]["title"]
end _SetProducerAttributes

private command _AddProducerProps @mltArray, producerKey, movieFile, producerLength, shotcutCaption
   put movie_CreationDate (movieFile) into creationTime
   --
   _AddProducerProperty mltArray, producerKey, 1, "length", producerLength
   _AddProducerProperty mltArray, producerKey, 2, "eof", "pause"
   _AddProducerProperty mltArray, producerKey, 3, "resource", movieFile
   _AddProducerProperty mltArray, producerKey, 4, "audio_index", 1
   _AddProducerProperty mltArray, producerKey, 5, "video_index", 0
   _AddProducerProperty mltArray, producerKey, 6, "mute_on_pause", 0
   _AddProducerProperty mltArray, producerKey, 7, "mlt_service", "avformat-novalidate"
   _AddProducerProperty mltArray, producerKey, 8, "seekable", 1
   _AddProducerProperty mltArray, producerKey, 9, "aspect_ratio", 1
   _AddProducerProperty mltArray, producerKey, 10, "creation_time", creationTime
   
   _AddProducerProperty mltArray, producerKey, 11, "ignore_points", 1
   _AddProducerProperty mltArray, producerKey, 12, "shotcut:caption", shotcutCaption
   _AddProducerProperty mltArray, producerKey, 13, "shotcut:skipConvert", 1
   _AddProducerProperty mltArray, producerKey, 14, "global_feed", 1
   _AddProducerProperty mltArray, producerKey, 15, "xml", "was here"
   
   -- put melt_GetShotCutHash (movieFile) into shotcutHash
   -- _AddProducerProperty mltArray, producerKey, 16, "shotcut:hash", shotcutHash
   
   return shotcutHash
end _AddProducerProps

private command _AddProducerProperty @mltArray, producerKey, pNum, pKey, pValue
   put "property[" & pNum & "]" into propertyKey
   --
   put pKey into mltArray ["mlt"][producerKey][propertyKey]["@attributes"]["name"]
   put pValue into mltArray ["mlt"][producerKey][propertyKey]["@value"]
end _AddProducerProperty

private command _AddPlayListEntry @mltArray, entryKey, inTime, outTime, producerID
   put producerID into mltArray ["mlt"]["xplaylist[1]"][entryKey]["@attributes"]["producer"]
   put inTime into mltArray ["mlt"]["xplaylist[1]"][entryKey]["@attributes"]["in"]
   put outTime into mltArray ["mlt"]["xplaylist[1]"][entryKey]["@attributes"]["out"]
end _AddPlayListEntry

private command _SetAttributes @mltArray
   put "C" into mltArray ["mlt"]["@attributes"]["LC_NUMERIC"]
   --
   put "main_bin" into mltArray ["mlt"]["@attributes"]["producer"]
   put "Shotcut version 20.02.17" into mltArray ["mlt"]["@attributes"]["title"]
   put "6.20.0" into mltArray ["mlt"]["@attributes"]["version"]
end _SetAttributes

command _AddProfile @mltArray, someHeigth, someWidth
   put 709 into mltArray ["mlt"]["profile"]["@attributes"]["colorspace"]
   put "automatic" into mltArray ["mlt"]["profile"]["@attributes"]["description"] 
   put 1001 into mltArray ["mlt"]["profile"]["@attributes"]["frame_rate_den"]
   put 30000 into mltArray ["mlt"]["profile"]["@attributes"]["frame_rate_num"]
   put 1 into mltArray ["mlt"]["profile"]["@attributes"]["sample_aspect_den"]
   put 1 into mltArray ["mlt"]["profile"]["@attributes"]["sample_aspect_num"]
   --
   put someHeigth into mltArray ["mlt"]["profile"]["@attributes"]["display_aspect_den"]
   put someWidth into mltArray ["mlt"]["profile"]["@attributes"]["display_aspect_num"]
   
   put someHeigth into mltArray ["mlt"]["profile"]["@attributes"]["height"]
   put someWidth into mltArray ["mlt"]["profile"]["@attributes"]["width"]
   --
   put 1 into mltArray ["mlt"]["profile"]["@attributes"]["progressive"]
end _AddProfile

private command _SetPlayListAttributes @mltArray
   put "main_bin" into mltArray ["mlt"]["xplaylist[1]"]["@attributes"]["id"]
   put "Shotcut version 20.02.17" into mltArray ["mlt"]["xplaylist[1]"]["@attributes"]["title"]
   --
   put "shotcut:projectAudioChannels" into mltArray ["mlt"]["xplaylist[1]"]["property[1]"]["@attributes"]["name"]
   put "2" into mltArray ["mlt"]["xplaylist[1]"]["property[1]"]["@value"]
   --
   put "shotcut:projectFolder" into mltArray ["mlt"]["xplaylist[1]"]["property[2]"]["@attributes"]["name"]
   put "0" into mltArray ["mlt"]["xplaylist[1]"]["property[2]"]["@value"]
end _SetPlayListAttributes


--> Deps
-
