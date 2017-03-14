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
          , authorProfiling = defaultAuthorProfiling
          , attribution = defaultAuthorRecognition
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
                    ( model
                        |> mapAttribution (\attribution -> { attribution | result = Just fromServer })
                    , Cmd.none
                    )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ChangeRoute newRoute ->
            ( { model | route = newRoute }, Cmd.none )

        UploadAuthorRecognition ->
            ( model, performAttribution model.attribution )

        UploadAuthorProfiling ->
            ( model, Cmd.none )

        ToggleKnownAuthorInputMode ->
            ( model
                |> mapAttribution (\attribution -> { attribution | knownAuthorMode = toggleInputMode attribution.knownAuthorMode })
            , Cmd.none
            )

        ToggleUnknownAuthorInputMode ->
            ( model
                |> mapAttribution (\attribution -> { attribution | unknownAuthorMode = toggleInputMode attribution.unknownAuthorMode })
            , Cmd.none
            )

        ToggleProfilingInputMode ->
            let
                old =
                    model.authorProfiling

                new =
                    { old | profilingMode = toggleInputMode old.profilingMode }
            in
                ( { model | authorProfiling = new }, Cmd.none )

        SetKnownAuthorText newText ->
            ( model
                |> mapAttribution (\attribution -> { attribution | knownAuthorText = newText })
            , Cmd.none
            )

        SetProfilingText newText ->
            let
                old =
                    model.authorProfiling

                new =
                    { old | profilingText = newText }
            in
                ( { model | authorProfiling = new }, Cmd.none )

        SetUnknownAuthorText newText ->
            ( model
                |> mapAttribution (\attribution -> { attribution | unknownAuthorText = newText })
            , Cmd.none
            )

        SetLanguage newLanguage ->
            ( model
                |> mapAttribution (\attribution -> { attribution | language = newLanguage })
            , Cmd.none
            )


performAttribution : AttributionState -> Cmd Msg
performAttribution attribution =
    let
        toServer =
            { knownAuthorText = attribution.knownAuthorText, unknownAuthorText = attribution.unknownAuthorText }

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
