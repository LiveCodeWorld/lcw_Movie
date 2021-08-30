script "lib_MovieDB"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_MovieDB
type: library
version: 0.1

/*
This library is for interfacing with the public movie database themmoviedb.org

- https://developers.themoviedb.org/3/getting-started/images
*/


--> Working on
-
command ask_SearchMovieDB pType
   if pType is empty then put "Multi" into pType
   --
   put ask_Question ("What would you like to search fo:", "Jack Reacher", "themoviedb.org") into searchString
   put movieDB_Search (searchString, pType) into sArray
   
   display_Data sArray, pType, "themoviedb.org"
end ask_SearchMovieDB

function test_MovieDB
   put movieDB_ConstructRestURl ("movie/550") into restURL
   return _GetRestData (restURL)
end test_MovieDB

function movieDB_ConstructRestURl restBit
   -- put "https://api.themoviedb.org/3/movie/550" into restURL
   put "https://api.themoviedb.org/3/" & restBit into restStem
   put restStem & "?api_key=" & movieDB_GetApikey() after restURL
   return restURL
end movieDB_ConstructRestURl

function movieDB_GetApikey
   put secret_Get ("apiKeyv3", "MovieDB") into apiKey
   return apiKey
end movieDB_GetApikey

command movieDB_SetApiKey apiKey
   secret_Set "apiKeyv3", apiKey, "MovieDB"
   return the result
end movieDB_SetApiKey


--> MovieDB
-
function movieDB_Search searchString, pType
   -- put "https://api.themoviedb.org/3/search/movie?api_key={api_key}&query=Jack+Reacher"
   put "search/" into restBit
   switch pType
      case "collection"
         put "collection" after restBit
         break
      case "company"
         put "company" after restBit
         break
      case "keyword"
         put "keyword" after restBit
         break
      case "all"
      case "multi"
         put "multi" after restBit
         break
      case "people"
      case "person"
         put "person" after restBit
         break
      case "tv"
         put "tv" after restBit
         break
      default
         put "movie" after restBit
   end switch
   
   put movieDB_ConstructRestURl (restBit) into restURL
   put "&query=" & urlEncode (searchString) after restURL
   --
   return _GetRestData (restURL)
end movieDB_Search


--> Deps
-
private function _GetRestData restURL
   put url restURL into sJSON
   put json_ToArray (sJSON) into sArray
   return sArray
end _GetRestData
