module Message exposing (..)

import Http
import Model exposing (Feed)


type Msg
    = ToggleLike
    | UpdateComment String
    | SaveComment
    | LoadFeed (Result Http.Error Feed)
