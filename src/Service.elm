module Service exposing (fetchPhotoFeed, wsUrl)

import Adapter exposing (photoDecoder)
import Http
import Json.Decode exposing (list)
import Message exposing (..)


wsUrl : String
wsUrl =
    "wss://programming-elm.com"


baseUrl : String
baseUrl =
    "https://programming-elm.com"


fetchPhotoFeed : Cmd Msg
fetchPhotoFeed =
    Http.get
        { url = baseUrl ++ "/feed"
        , expect = Http.expectJson LoadFeed (list photoDecoder)
        }
