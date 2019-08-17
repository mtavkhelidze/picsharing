module Message exposing (..)

import Http
import Model exposing (Feed, Id)


type Msg
    = ToggleLike Id
    | UpdateComment Id String
    | SaveComment Id
    | LoadFeed (Result Http.Error Feed)
