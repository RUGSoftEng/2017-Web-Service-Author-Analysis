module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onWithOptions, defaultOptions)
import Json.Decode as Decode
import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col


{-| Our model of the world
-}
type alias Model =
    { navbarState : Navbar.State, authorRecognition : AuthorRecognitionState }


type alias AuthorRecognitionState =
    { knownAuthorMode : InputMode }


initialState : ( Model, Cmd Msg )
initialState =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        defaultAuthorRecognition =
            { knownAuthorMode = PasteText }
    in
        ( { navbarState = navbarState
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
    | ToggleKnownAuthorInputMode


{-| How our model should change when a message comes in
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ToggleKnownAuthorInputMode ->
            let
                old =
                    model.authorRecognition

                new =
                    { old | knownAuthorMode = toggleInputMode old.knownAuthorMode }
            in
                ( { model | authorRecognition = new }, Cmd.none )


{-| How the model is displayed
-}
view : Model -> Html Msg
view model =
    div []
        [ CDN.stylesheet
        , navbar model
        , authorRecognitionView model.authorRecognition
        ]


authorRecognitionView : AuthorRecognitionState -> Html Msg
authorRecognitionView authorRecognition =
    let
        knownAuthorInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Known Author" ]
                , knownButtons
                , textarea [ style [ ( "width", "100%" ) ] ] []
                ]

        separator =
            Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ] [ text "compare with" ]

        knownButtons =
            let
                pasteText =
                    authorRecognition.knownAuthorMode == PasteText
            in
                radioButtons "known-author-inputmode"
                    [ ( pasteText, ToggleKnownAuthorInputMode, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleKnownAuthorInputMode, [ text "Upload File" ] )
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
                    [ knownAuthorInput
                    , separator
                      -- unknownAuthorInput goes here
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
        |> Navbar.brand [ href "#", onClick NoOp ] [ text "Home" ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#", onClick NoOp ] [ text "Author Recognition" ]
            , Navbar.itemLink [ href "#", onClick NoOp ] [ text "Profiling" ]
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
