module Pages.Profiling exposing (..)

import Http


--

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder, checked)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Progress as Progress


--

import Data.Profiling.Input
import Data.File exposing (File)
import Data.Language as Language exposing (Language(..))
import InputField
import Route


type alias Model =
    Data.Profiling.Input.Input


{-| Initial state of the Attribution page

-}
init : Model
init =
    { text = InputField.init
    , language = EN
    , languages = [ EN, NL ]
    }


{-| external functions that we'll inject into the Attribution page

Both of these handle communication with the outside world. It's nicer
to bundle everything that does communication, keeping the separate pages ignorant.
-}
type alias Config msg =
    { readFiles : ( String, String ) -> Cmd msg
    }


type Msg
    = SetLanguage Language
    | InputFieldMsg InputField.Msg
    | LoadExample


{-| Update the Attribution page
* InputFieldMsg
    Given a message for an InputField, update the correct input field with that message.
    Then put everything back in the model and execute any commands that InputField.update may have returned.
The other three messages are simple setters of data.
-}
update : Config InputField.Msg -> Msg -> Model -> ( Model, Cmd Msg )
update config msg profiling =
    case msg of
        InputFieldMsg msg ->
            let
                updateConfig : InputField.UpdateConfig
                updateConfig =
                    { readFiles = config.readFiles ( "profiling-file-input", "Profiling" )
                    }

                ( newInput, inputCommands ) =
                    InputField.update updateConfig msg profiling.text
            in
                ( { profiling | text = newInput }
                , Cmd.map InputFieldMsg inputCommands
                )

        SetLanguage newLanguage ->
            ( { profiling | language = newLanguage }
            , Cmd.none
            )

        LoadExample ->
            ( profiling, Cmd.none )


addFile : ( String, File ) -> Model -> Model
addFile ( identifier, file ) profiling =
    case identifier of
        "Profiling" ->
            { profiling | text = InputField.addFile file profiling.text }

        _ ->
            Debug.crash <| "File with invalid id `" ++ identifier ++ "` cannot be added"


{-| Subscriptions for the animation of FileInput's cards, used for the file upload UI.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ InputField.subscriptions model.text
            |> Sub.map (InputFieldMsg)
        ]



-- View


view : Model -> Html Msg
view profiling =
    div [ class "content" ]
        [ Grid.container []
            [ Grid.row [ Row.topXs ]
                [ Grid.col []
                    [ h1 [] [ text "Go Profiling" ]
                    , span [ class "explanation" ]
                        [ text "The Author Profiling System will, given a text, try to predict its author's age and gender."
                        ]
                    ]
                ]
            , Grid.row [ Row.attrs [ class "boxes" ] ]
                [ textInput profiling.text
                ]
            , Grid.row []
                [ Grid.col [ Col.attrs [ class "text-center box submission" ] ]
                    [ Button.linkButton [ Button.primary, Button.attrs [ Route.href Route.ProfilingPrediction, id "compare-button" ] ] [ text "Analyze!" ]
                    ]
                ]
              {-
                 , Grid.row []
                     [ Grid.col [ Col.attrs [ class "text-center" ] ]
                         [ Button.button [ Button.secondary, Button.attrs [ id "compare-button", onClick (LoadExample SameAuthor) ] ] [ text "Load Example - same authors" ]
                         , Button.button [ Button.secondary, Button.attrs [ id "compare-button", onClick (LoadExample DifferentAuthor) ] ] [ text "Load Example - different authors" ]
                         ]
                     ]
              -}
            , Grid.row [ Row.attrs [ class "boxes settings" ] ] (settings profiling)
            ]
        ]


textInput : InputField.Model -> Grid.Column Msg
textInput text =
    let
        {- config for an InputField

           * label: UI name for this field
           * radioButtonName: internal `name` attribute for the radio buttons
           * fileInputId: id for the <input> element where files for this InputField are stored
           * multiple: can multiple files be uploaded at once
        -}
        config : InputField.ViewConfig
        config =
            { label = "Text"
            , radioButtonName = "profiling-buttons"
            , fileInputId = "profiling-file-input"
            , info = "Place here the text you want to analyze"
            , multiple = False
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center box" ] ] <|
            (InputField.view config text
                |> List.map (Html.map InputFieldMsg)
            )


settings : Model -> List (Grid.Column Msg)
settings profiling =
    let
        languageRadio language =
            li []
                [ label []
                    [ input
                        [ type_ "radio"
                        , checked (language == profiling.language)
                        , onClick (SetLanguage language)
                        ]
                        []
                    , text (toString language)
                    ]
                ]
    in
        [ Grid.col [ Col.attrs [ class "text-center box" ] ]
            [ h2 [] [ text "Language" ]
            , span [] [ text "Select the language in which all texts are written" ]
            , ul [] (List.map languageRadio profiling.languages)
            ]
        ]
