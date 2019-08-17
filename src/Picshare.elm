module Picshare exposing (main)

import Adapter exposing (photoDecoder)
import Browser
import Json.Decode exposing (decodeString)
import Message exposing (..)
import Model exposing (Feed, Id, Model, Photo, initialModel)
import Service exposing (fetchPhotoFeed, wsUrl)
import View exposing (view)
import WebSocket


toggleLike : Photo -> Photo
toggleLike photo =
    { photo | liked = not photo.liked }


updateComment : String -> Photo -> Photo
updateComment txt photo =
    { photo | newComment = txt }


updatePhotoById : (Photo -> Photo) -> Id -> Feed -> Feed
updatePhotoById updatePhoto id feed =
    List.map
        (\photo ->
            if photo.id == id then
                updatePhoto photo

            else
                photo
        )
        feed


updateFeed : (Photo -> Photo) -> Id -> Maybe Feed -> Maybe Feed
updateFeed updatePhoto id maybeFeed =
    Maybe.map (updatePhotoById updatePhoto id) maybeFeed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadFeedPhoto (Ok photo) ->
            ( { model | queue = photo :: model.queue }, Cmd.none )

        LoadFeedPhoto (Err _) ->
            ( model, Cmd.none )

        FlushStreamQueue ->
            ( { model
                | feed = Maybe.map ((++) model.queue) model.feed
                , queue = []
              }
            , Cmd.none
            )

        ToggleLike id ->
            ( { model | feed = updateFeed toggleLike id model.feed }
            , Cmd.none
            )

        UpdateComment id txt ->
            ( { model | feed = updateFeed (updateComment txt) id model.feed }
            , Cmd.none
            )

        SaveComment id ->
            ( { model | feed = updateFeed saveNewComment id model.feed }
            , Cmd.none
            )

        LoadFeed (Ok feed) ->
            ( { model | feed = Just feed }
            , WebSocket.listen wsUrl
            )

        LoadFeed (Err error) ->
            ( { model | error = Just error }, Cmd.none )


saveNewComment : Photo -> Photo
saveNewComment model =
    let
        comment =
            String.trim model.newComment
    in
    case comment of
        "" ->
            model

        _ ->
            { model
                | comments = model.comments ++ [ comment ]
                , newComment = ""
            }


subscriptions : Model -> Sub Msg
subscriptions _ =
    WebSocket.receive (LoadFeedPhoto << decodeString photoDecoder)


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, fetchPhotoFeed )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
