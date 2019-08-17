module Picshare exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Message exposing (..)
import Model exposing (Feed, Photo)
import Service exposing (fetchPhotoFeed)


type alias Model =
    { feed : Maybe Feed }


initialModel : Model
initialModel =
    { feed = Nothing }


toggleLike : Photo -> Photo
toggleLike photo =
    { photo | liked = not photo.liked }


updateComment : String -> Photo -> Photo
updateComment txt photo =
    { photo | newComment = txt }


updateFeed : (Photo -> Photo) -> Maybe Photo -> Maybe Photo
updateFeed updatePhoto maybePhoto =
    Maybe.map updatePhoto maybePhoto


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        --        ToggleLike ->
        --            ( { model | photo = updateFeed toggleLike model.photo }
        --            , Cmd.none
        --            )
        --
        --        UpdateComment txt ->
        --            ( { model | photo = updateFeed (updateComment txt) model.photo }
        --            , Cmd.none
        --            )
        --
        --        SaveComment ->
        --            ( { model | photo = updateFeed saveNewComment model.photo }
        --            , Cmd.none
        --            )
        LoadFeed (Ok feed) ->
            ( { model | feed = Just feed }
            , Cmd.none
            )

        LoadFeed (Err _) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


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


viewFeed : Maybe Feed -> Html Msg
viewFeed maybeFeed =
    case maybeFeed of
        Just feed ->
            div [] (List.map viewDetailedPhoto feed)

        Nothing ->
            div [ class "loading-feed" ] [ text "Loading feed..." ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 [] [ text "Picture Share v2.0" ] ]
        , div [ class "content-flow" ]
            [ viewFeed model.feed ]
        ]


viewComment : String -> Html Msg
viewComment comment =
    li []
        [ strong [] [ text "Comment:" ]
        , text (" " ++ comment)
        ]


viewCommentList : List String -> Html Msg
viewCommentList comments =
    case comments of
        [] ->
            text ""

        _ ->
            div [ class "comments" ]
                [ ul [] (List.map viewComment comments)
                ]


viewComments : Photo -> Html Msg
viewComments photo =
    div []
        [ viewCommentList photo.comments
        , Html.form
            [ class "new-comment"

            -- , onSubmit SaveComment
            ]
            [ input
                [ type_ "text"
                , placeholder "Add a comment"
                , value photo.newComment

                -- , onInput UpdateComment
                ]
                []
            , button
                [ disabled (String.isEmpty photo.newComment) ]
                [ text "Save" ]
            ]
        ]


viewLikeButton : Photo -> Html Msg
viewLikeButton photo =
    let
        cx =
            if photo.liked then
                "fa-heart"

            else
                "fa-heart-o"
    in
    div [ class "like-button" ]
        [ i
            [ class "fa fa-2x"
            , class cx

            -- , onClick ToggleLike
            ]
            []
        ]


viewDetailedPhoto : Photo -> Html Msg
viewDetailedPhoto photo =
    div [ class "detailed-photo" ]
        [ img [ src photo.url ] []
        , div [ class "photo-info" ]
            [ viewLikeButton photo
            , h2 [ class "caption" ] [ text photo.caption ]
            , viewComments photo
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


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
