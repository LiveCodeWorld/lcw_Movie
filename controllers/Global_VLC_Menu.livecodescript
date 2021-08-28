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


--> Global | VLC | Menu
-
on menu_ShellPause
   put "" into uName
   put "b05m3g" into pWord
   put "pl_pause" into sCommand
   --
   get merge ("curl -s -u :[[pWord]] 'http://127.0.0.1:8080/requests/status.xml?command=[[sCommand]]'")
   put shell (it) into shellResult
end menu_ShellPause

on menu_RestPause
   vlc_Pause
   
   /*
   put "" into uName
   put "b05m3g" into pWord
   put "pl_pause" into sCommand
   --
   put merge ("http://127.0.0.1:8080/requests/status.xml?command=pl_pause") into vlcURL
   --
   http_SetBasicAuthentication uName, pWord
   get url vlcURL
   -- put libURLLastHTTPHeaders() & CR&CR & libURLLastRHHeaders()
   */
end menu_RestPause

on _
end _

on menu_SetPage displayView
   open datagram socket to "127.0.0.1:51235"
   write "PAGE-SET 1 BL15K1B43145" to socket "127.0.0.1:51235" with message "socketFinishedWriting"
end menu_SetPage

on menu_BankPress displayView
   open datagram socket to "127.0.0.1:51235"
   write "BANK-PRESS 1 11" to socket "127.0.0.1:51235" with message "socketFinishedWriting"
end menu_BankPress
