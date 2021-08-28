script "Global | Glitch | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Glitch | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

getprop menu_Target [cardObject]
   put the long id of player 1 of cardObject into playerObject
   return playerObject
end menu_Target

getprop uploadToWiki_Params
   return "conversation.wiki,permanent.wiki,-,vlog.mediagarden.org"
end uploadToWiki_Params


--> Global | Glitch | Menu
-
on menu_PlayNext playerObject
   put the duration of playerObject into lastIntervalNum
   
   -- The callbacks of a player is a list of callbacks, one per line. Each callback consists of an interval number, a comma, and a message name. 
   put lastIntervalNum,"nextVideo" into messageList
   --
   set the callbacks of playerObject to messageList
end menu_PlayNext

on _
end _

on submenu_Movie
   return "Global | Movie | Menu"
end submenu_Movie

on _
end _

on menu_RenameFile playerObject
   put the movie_File of playerObject into mFile
   set the itemdelimiter to slash
   put item -1 of mFile into shortFile
   --
   put lcw_Ask ("Rename movie file...", shortFile, playerObject) into newShortFile
   if newShortFile is empty then exit to top
   --
   put mFile into newPath
   put newShortFile into item -1 of newPath
   rename file mFile to newPath
   --
   set the movie_File of playerObject to newPath
end menu_RenameFile

on menu_UploadToWiki playerObject, wikiDomain
   put the movie_File of playerObject into mFile
   if mFile is empty then
      lcw_AnswerWarning "Player has no file!", playerObject
   end if
   --
   put "Test Movie Upload" into mTitle
   put "Just testing uploading a movie with Livecode" into mDescription
   
   atopia_UploadRecording mFile, mTitle, mDescription, wikiDomain
   --
   if the result is empty then
      answer "Uploaded asset!"
   else
      put the result
      answer "Failed to upload file :("
   end if
end menu_UploadToWiki

on menu_Reveal playerObject
   put the movie_File of playerObject into mFile
   finder_Reveal mFile
end menu_Reveal

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_YoutubeDownloadConfig
   folder_CreateNested "~/.config/youtube-dl/"
   folder_CreateNested "~/Movies/Youtube/"
   --
   put "~/.config/youtube-dl/config" into cFile
   if there is not a file cFile then
      put "# Lines starting with # are comments" into defaultConfig
      put CR&CR & "# Remove spaces and funny chars from filename" after defaultConfig
      put CR & "--restrict-filenames" after defaultConfig
      put CR&CR & "# Save all videos under Movies directory in your home directory" after defaultConfig
      put CR & "-o ~/Movies/Youtube/%(title)s-%(id)s.%(ext)s" after defaultConfig
      --
      put defaultConfig into url ("file:" & cFile)
   end if
   --
   atom_Edit cFile
end menu_YoutubeDownloadConfig

on menu_IgnoreOverdueIplayer
   put "get_iplayer --prefs-add --no-purge" into someShell
   put shell (someShell)
end menu_IgnoreOverdueIplayer

on _
end _

on menu_EditBehavior playerObject
   put the behavior of playerObject into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_RevealMovie playerObject
   put the filename of playerObject into mFile
   put mFile
   finder_Reveal mFile
end menu_RevealMovie


--> Deps
-
