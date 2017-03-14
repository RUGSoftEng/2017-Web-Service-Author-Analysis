module Update exposing (update, initialState)

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Http
import Bootstrap.Navbar as Navbar
import View
import Types exposing (..)


initialState : ( Model, Cmd Msg )
initialState =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        defaultAuthorRecognition =
            { knownAuthorMode = PasteText
            , knownAuthorText = ""
            , unknownAuthorMode = PasteText
            , unknownAuthorText = ""
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


toggleInputMode : InputMode -> InputMode
toggleInputMode mode =
    case mode of
        FileUpload ->
            PasteText

        PasteText ->
            FileUpload


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


performAuthorRecognition : AuthorRecognitionState -> Cmd Msg
performAuthorRecognition authorRecognition =
    let
        toServer =
            { knownAuthorText = authorRecognition.knownAuthorText, unknownAuthorText = authorRecognition.unknownAuthorText }

        body =
            Http.jsonBody (encodeToServer toServer)
    in
        Http.post (webserverUrl ++ authorRecognitionEndpoint) body decodeFromServer
            |> Http.send ServerResponse


webserverUrl : String
webserverUrl =
    "http://localhost:8080"


authorRecognitionEndpoint : String
authorRecognitionEndpoint =
    "/api/attribution"


fillerText1 =
    """Leverage agile frameworks to provide a robust synopsis for high level overviews. Iterative approaches to corporate strategy foster collaborative thinking to further the overall value proposition. Organically grow the holistic world view of disruptive innovation via workplace diversity and empowerment.
"""


fillerText2 =
    """This is the update of Unknown Author.
"""
