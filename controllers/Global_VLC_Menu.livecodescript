script "Global | VLC | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | VLC | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/


--> Variables
-
local LocalArray

--> Menu | Props
-
/*
/requests/playlist.xml - Retrieve current playlist in XML format
/requests/status.xml?command=pl_empty - Clear current playlist
/requests/status.xml?command=in_enqueue&input=<uri> - Add URI to playlist (example)
/requests/status.xml?command=in_play&input=<uri> - Add URI to playlist and start playing

$request .= 'Authorization: Basic ' . base64_encode(':' . $cfg['player_pass']) . "\r\n\r\n";
*/

getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

command socketFinishedWriting pSocketID
   put "Data written to socket" && pSocketID
   close socket pSocketID
end socketFinishedWriting

getprop checked_FullScreen
   put the vlc_StatusArray of stack "Fun" into statusArray
   return statusArray ["fullscreen"] is true
end checked_FullScreen


--> Global | VLC | Menu
-
on menu_SearchIplayer
   put the vlc_StatusArray of stack "Fun" into statusArray
   put statusArray ["information"]["category"]["meta"]["filename"] into shortFile
   put statusArray ["information"]["category"]["meta"]["Writer"] into sWriter
   put statusArray ["information"]["category"]["meta"]["title"] into sTitle
end menu_SearchIplayer

on menu_FullScreen
   get the vlc_ToggleFullScreen of stack "Fun"
end menu_FullScreen

on menu_SearchTv
   ask_SearchMovieDB tv
end menu_SearchTv

on menu_Docummentation
   launch url "http://livecode.world/view/welcome-visitors/view/vlc"
end menu_Docummentation

on menu_LaunchInterface
   put the name of stack "Fun" into mObject
   --
   put the vlc_IP of mObject into someIP
   put the vlc_Port of mObject into somePort
   --
   put merge ("http://[[someIP]]:[[somePort]]") into someURL
   -- put "http://127.0.0.1:8080" into someURL
   --
   launch url someURL
end menu_LaunchInterface

on menu_DisplayStatus
   display_VlcStatus "Fun"
end menu_DisplayStatus

on menu_DisplayPlayList
   display_VlcPlayList "Fun"
end menu_DisplayPlayList

on menu_DisplayBrowseArray
   display_VlcBrowseArray "Fun"
end menu_DisplayBrowseArray

on _
end _

on menu_StreamDeckPage displayView
   open datagram socket to "127.0.0.1:51235"
   write "PAGE-SET 1 BL15K1B43145" to socket "127.0.0.1:51235" with message "socketFinishedWriting"
end menu_StreamDeckPage

on menu_StreamDeckBankPress displayView
   open datagram socket to "127.0.0.1:51235"
   write "BANK-PRESS 1 11" to socket "127.0.0.1:51235" with message "socketFinishedWriting"
end menu_StreamDeckBankPress


--> Dev | Menu
-
on _ShellPause
   put "" into uName
   put "b05m3g" into pWord
   put "pl_pause" into sCommand
   --
   get merge ("curl -s -u :[[pWord]] 'http://127.0.0.1:8080/requests/status.xml?command=[[sCommand]]'")
   put shell (it) into shellResult
end _ShellPause

