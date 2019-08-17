module Message exposing (..)

import Http
import Json.Decode
import Model exposing (Feed, Id, Photo)


type Msg
    = ToggleLike Id
    | UpdateComment Id String
    | SaveComment Id
    | LoadFeed (Result Http.Error Feed)
    | LoadFeedPhoto (Result Json.Decode.Error Photo)
    | FlushStreamQueue
