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
    { route : Route, navbarState : Navbar.State, authorRecognition : AuthorRecognitionState }


type alias AuthorRecognitionState =
    { knownAuthorMode : InputMode
    , knownAuthorText : String
    , unknownAuthorMode : InputMode
    , unknownAuthorText : String
    , result : Maybe FromServer
    }


type Route
    = Home
    | AuthorRecognition
    | Profiling


homeView : Html msg
homeView =
    text "home"


profilingView : Html msg
profilingView =
    text "profiling"


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
            }
    in
        ( { route = AuthorRecognition
          , navbarState = navbarState
          , authorRecognition = defaultAuthorRecognition
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
    | ToggleKnownAuthorInputMode
    | ToggleUnknownAuthorInputMode
    | SetKnownAuthorText String
    | SetUnknownAuthorText String
    | ServerResponse (Result Http.Error FromServer)


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


{-| How the model is displayed
-}
view : Model -> Html Msg
view model =
    div []
        [ CDN.stylesheet
        , node "style"
            []
            [ text """
.btn-primary.active {
    background-color: #DC002D;
    border-color: #DC002D;
    }

.btn-primary {
    background-color: #A90023;
    border-color: #A90023;
    }

.btn-primary:hover {
    background-color: #DC002D;
    border-color: #DC002D;
    }



        """
            ]
        , navbar model
        , case model.route of
            Home ->
                homeView

            AuthorRecognition ->
                authorRecognitionView model.authorRecognition

            Profiling ->
                profilingView
        , footer [ class "footer" ] [ footerbar model ]
        ]


authorRecognitionView : AuthorRecognitionState -> Html Msg
authorRecognitionView authorRecognition =
    let
        knownAuthorInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Known Author" ]
                , knownButtons
                , textarea
                    [ onInput SetKnownAuthorText
                    , defaultValue authorRecognition.knownAuthorText
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

        unknownAuthorInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Unknown Author" ]
                , unknownButtons
                , textarea
                    [ onInput SetUnknownAuthorText
                    , defaultValue authorRecognition.unknownAuthorText
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

        result =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "result: " ]
                , case authorRecognition.result of
                    Nothing ->
                        text ""

                    Just a ->
                        text (toString a)
                ]

        separator =
            Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ]
                [ Button.button [ Button.primary, Button.attrs [ onClick UploadAuthorRecognition ] ] [ text "compare with" ] ]

        knownButtons =
            let
                pasteText =
                    authorRecognition.knownAuthorMode == PasteText
            in
                radioButtons "known-author-inputmode"
                    [ ( pasteText, ToggleKnownAuthorInputMode, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleKnownAuthorInputMode, [ text "Upload File" ] )
                    ]

        unknownButtons =
            let
                pasteText =
                    authorRecognition.unknownAuthorMode == PasteText
            in
                radioButtons "unknown-author-inputmode"
                    [ ( pasteText, ToggleUnknownAuthorInputMode, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleUnknownAuthorInputMode, [ text "Upload File" ] )
                    ]
    in
        div []
            [ div [ class "jumbotron" ]
                [ Grid.container []
                    [ h1 [ class "display-3" ] [ text "Author Recognition" ]
                    , p [] [ text "Predict whether two texts are written by the same author" ]
                    ]
                ]
            , Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ result ]
                , Grid.row [ Row.topXs ]
                    [ knownAuthorInput
                    , separator
                    , unknownAuthorInput
                    ]
                ]
            ]


{-| we have to do this html manually, until my fix to the elm-bootstrap package gets merged
(this should be early next week, I spoke with the package author).

Until then, just assume this function works
-}
radioButtons : String -> List ( Bool, msg, List (Html msg) ) -> Html msg
radioButtons groupName options =
    let
        viewRadioButton ( checked, onclick, children ) =
            label
                [ classList [ ( "btn", True ), ( "btn-primary", True ), ( "active", checked ) ]
                , onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed onclick)
                ]
                (input [ attribute "autocomplete" "off", attribute "checked" "", name groupName, type_ "radio" ] [] :: children)
    in
        div [ class "btn-group", attribute "data-toggle" "buttons" ] (List.map viewRadioButton options)


{-| The bar on the top

For now, clicking the links will fire a NoOp. We will implement the switching between pages later
-}
navbar : Model -> Html Msg
navbar ({ navbarState } as model) =
    Navbar.config NavbarMsg
        |> Navbar.inverse
        |> Navbar.withAnimation
        |> Navbar.brand [ href "#", onClick (ChangeRoute Home) ] [ text "Author Analysis | " ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#", onClick (ChangeRoute AuthorRecognition) ] [ text "Attribution" ]
            , Navbar.itemLink [ href "#", onClick (ChangeRoute Profiling) ] [ text "Profiling" ]
            ]
        |> Navbar.view navbarState


footerbar : Model -> Html Msg
footerbar ({ navbarState } as model) =
    Navbar.config NavbarMsg
        |> Navbar.inverse
        |> Navbar.fixBottom
        |> Navbar.withAnimation
        |> Navbar.items
            [ Navbar.itemLink [ href "#", onClick (ChangeRoute AuthorRecognition) ] [ text "" ]
            ]
        |> Navbar.customItems
            [ Navbar.customItem <|
                div
                    [ href "#"
                    , class "pull-right"
                    ]
                    [ img [ src "https://nestor.rug.nl/branding/themes/student-portal-2016/rugimg/rug_logo_en.png", class "d-inline-block align-top", style [ "height" => "30px" ] ] [] ]
            ]
        |> Navbar.view navbarState


main : Program Never Model Msg
main =
    Html.program
        { update = update
        , view = view
        , init = initialState
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navbarState NavbarMsg


fillerText1 =
    """Leverage agile frameworks to provide a robust synopsis for high level overviews. Iterative approaches to corporate strategy foster collaborative thinking to further the overall value proposition. Organically grow the holistic world view of disruptive innovation via workplace diversity and empowerment.\x0D
"""


fillerText2 =
    """This is the update of Unknown Author.\x0D
"""



-- this is experimental stuff


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


(=>) =
    (,)


webserverUrl =
    "http://localhost:8080"


authorRecognitionEndpoint =
    "/api/attribution"


{-| Request to the server

Example JSON:
{ "knownAuthorText": "lorem", "unknownAuthorText": "ipsum" }

-}
type alias ToServer =
    { knownAuthorText : String, unknownAuthorText : String }


{-| Response from the server

Example JSON:
{ "sameAuthor": true, "confidence": 0.67 }

-}
type alias FromServer =
    { sameAuthor : Bool, confidence : Float }


encodeToServer : ToServer -> Encode.Value
encodeToServer toServer =
    Encode.object
        [ "knownAuthorText" => Encode.string toServer.knownAuthorText
        , "unknownAuthorText" => Encode.string toServer.unknownAuthorText
        ]


decodeFromServer : Decode.Decoder FromServer
decodeFromServer =
    Decode.succeed FromServer
        |> required "sameAuthor" bool
        |> required "confidence" float



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
-- access-control-allow-origin
