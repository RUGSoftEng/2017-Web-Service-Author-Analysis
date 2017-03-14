module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Http
import Json.Decode as Decode exposing (string, bool, int, float)
import Json.Decode.Pipeline as Decode exposing (..)
import Json.Encode as Encode
import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col


{-| Our model of the world
-}
type alias Model =
    { route : Route, navbarState : Navbar.State, authorRecognition : AuthorRecognitionState, authorProfiling: AuthorProfilingState }


type alias AuthorRecognitionState =
    { knownAuthorMode : InputMode
    , knownAuthorText : String
    , unknownAuthorMode : InputMode
    , unknownAuthorText : String
    , result : Maybe FromServer
    , language : Language
    }

type alias AuthorProfilingState =
    { profilingMode : InputMode
    , profilingText : String
    , result : Maybe FromServer2
    }

type Language
     = EN
     | NL

type Route
    = Home
    | AuthorRecognition
    | AuthorProfiling


homeView : Html msg
homeView =
    text "home"

initialState : ( Model, Cmd Msg )
initialState =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        defaultAuthorRecognition =
            { knownAuthorMode = PasteText
            , knownAuthorText = fillerText1
            , unknownAuthorMode = PasteText
            , unknownAuthorText = fillerText2
            , result = Just { sameAuthor = True, confidence = 0.5 }
            , language = EN
            }

        defaultAuthorProfiling =
            { profilingMode = PasteText
            , profilingText = fillerText1
            , result = Just { gender = "Male", age = 20 }
            }
    in
        ( { route = AuthorRecognition
          , navbarState = navbarState
          , authorRecognition = defaultAuthorRecognition
          , authorProfiling = defaultAuthorProfiling
          }
        , navbarCmd
        )


type InputMode
    = FileUpload
    | PasteText


toggleInputMode : InputMode -> InputMode
toggleInputMode mode =
    case mode of
        FileUpload ->
            PasteText

        PasteText ->
            FileUpload


{-| All the actions our application can perform
-}
type Msg
    = NoOp
    | NavbarMsg Navbar.State
    | ChangeRoute Route
    | UploadAuthorRecognition
    | UploadAuthorProfiling
    | ToggleKnownAuthorInputMode
    | ToggleUnknownAuthorInputMode
    | ToggleProfilingInputMode
    | SetKnownAuthorText String
    | SetUnknownAuthorText String
    | SetProfilingText String
    | ServerResponse (Result Http.Error FromServer)
    | SetLanguage Language


{-| How our model should change when a message comes in
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        ServerResponse resp ->
            case resp of
                Err error ->
                    ( model, Cmd.none )

                Ok fromServer ->
                    let
                        old =
                            model.authorRecognition

                        new =
                            { old | result = Just fromServer }
                    in
                        ( { model | authorRecognition = new }, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ChangeRoute newRoute ->
            ( { model | route = newRoute }, Cmd.none )

        UploadAuthorRecognition ->
            ( model, performAuthorRecognition model.authorRecognition )

        UploadAuthorProfiling ->
            ( model, Cmd.none )

        ToggleKnownAuthorInputMode ->
            let
                old =
                    model.authorRecognition

                new =
                    { old | knownAuthorMode = toggleInputMode old.knownAuthorMode }
            in
                ( { model | authorRecognition = new }, Cmd.none )

        ToggleUnknownAuthorInputMode ->
            let
                old =
                    model.authorRecognition

                new =
                    { old | unknownAuthorMode = toggleInputMode old.unknownAuthorMode }
            in
                ( { model | authorRecognition = new }, Cmd.none )

        ToggleProfilingInputMode ->
            let
                old =
                    model.authorProfiling

                new =
                    { old | profilingMode = toggleInputMode old.profilingMode }
            in
                ( { model | authorProfiling = new }, Cmd.none )

        SetKnownAuthorText newText ->
            let
                old =
                    model.authorRecognition

                new =
                    { old | knownAuthorText = newText }
            in
                ( { model | authorRecognition = new }, Cmd.none )

        SetUnknownAuthorText newText ->
            let
                old =
                    model.authorRecognition

                new =
                    { old | unknownAuthorText = newText }
            in
                ( { model | authorRecognition = new }, Cmd.none )

        SetProfilingText newText ->
            let
                old =
                    model.authorProfiling

                new =
                    { old | profilingText = newText }
            in
                ( { model | authorProfiling = new }, Cmd.none )

        SetLanguage language ->
            let
                old =
                    model.authorRecognition

                new =
                    { old | language = language }
            in
                ( { model | authorRecognition = new }, Cmd.none )


{-| How the model is displayed
-}
view : Model -> Html Msg
view model =
    div []
        [ CDN.stylesheet
        , node "style"
            []
            [ text """\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
.btn-primary.active {\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    background-color: #DC002D;\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    border-color: #DC002D;\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    }\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
.btn-primary {\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    background-color: #A90023;\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    border-color: #A90023;\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    }\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
.btn-primary:hover {\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    background-color: #DC002D;\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    border-color: #DC002D;\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
    }\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D
\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D\x0D

        """
            ]
        , navbar model
        , case model.route of
            Home ->
                homeView

            AuthorRecognition ->
                authorRecognitionView model.authorRecognition

            AuthorProfiling ->
                authorProfilingView model.authorProfiling
        , footer [ class "footer" ] [ footerbar model ]
        ]

This file wires all parts of the app together.
-}

import Bootstrap.Navbar as Navbar
import Html
import View
import Update
import Types exposing (Model, Msg(NavbarMsg))


main : Program Never Model Msg
main =
    Html.program
        { update = Update.update
        , view = View.view
        , init = Update.initialState
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navbarState NavbarMsg



{- }
   routeParser : Parser (Route -> a) a
   routeParser =
       oneOf
           [ map Home top
           , map AuthorRecognition (s "author-recognition")
           , map AuthorProfiling (s "author-profiling")
           ]


   route = parsePath routeParser location
-}
