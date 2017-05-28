module Pages.Profiling exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder, checked)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Views.Spinner exposing (spinner)


--

import Config.Profiling as Config
import Data.Profiling.Input
import Data.File exposing (File)
import Data.Language as Language exposing (Language(..))
import InputField
import Route
import I18n exposing (Translation)


type alias Model =
    Data.Profiling.Input.Input


{-| Initial state of the Attribution page

-}
init : Model
init =
    { text = InputField.init
    , language = Config.defaultLanguage
    , languages = Config.availableLanguages
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


textCenter =
    Col.attrs [ class "text-center" ]


loading : Translation -> Model -> Html Msg
loading translation attribution =
    let
        t key =
            I18n.get translation key
    in
        div [ class "content" ]
            [ Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ Grid.col []
                        [ h1 [] [ text "Profiling" ] ]
                    ]
                , Grid.row [] [ Grid.col [ textCenter ] [ spinner ] ]
                , Grid.row [] [ Grid.col [ textCenter ] [ h3 [] [ text "Performing Analysis" ] ] ]
                , Grid.row [] [ Grid.col [ textCenter ] [ Button.linkButton [ Button.attrs [ Route.href Route.Profiling ], Button.primary ] [ text "Cancel" ] ] ]
                ]
            ]


view : Translation -> Model -> Html Msg
view translation profiling =
    let
        t key =
            I18n.get translation key
    in
        div [ class "content" ]
            [ Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ Grid.col []
                        [ h1 [] [ text "Profiling" ]
                        , span [ class "explanation" ]
                            [ text (I18n.get translation "profiling-explanation")
                            ]
                        ]
                    ]
                , Grid.row [ Row.attrs [ class "boxes" ] ]
                    [ textInput t profiling.text
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
                , Grid.row [ Row.attrs [ class "boxes settings" ] ] (settings translation profiling)
                ]
            ]


textInput : (String -> String) -> InputField.Model -> Grid.Column Msg
textInput t text =
    let
        {- config for an InputField

           * label: UI name for this field
           * radioButtonName: internal `name` attribute for the radio buttons
           * fileInputId: id for the <input> element where files for this InputField are stored
           * multiple: can multiple files be uploaded at once
        -}
        config : InputField.ViewConfig
        config =
            { label = t "profiling-label"
            , radioButtonName = "profiling-buttons"
            , fileInputId = "profiling-file-input"
            , info = t "profiling-description"
            , multiple = False
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center box" ] ] <|
            (InputField.view config text
                |> List.map (Html.map InputFieldMsg)
            )


settings : Translation -> Model -> List (Grid.Column Msg)
settings translation profiling =
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
        [ Grid.col [ Col.attrs [ class "text-left box" ] ]
            [ h2 [] [ text "Language" ]
            , span [] [ text (I18n.get translation "profiling-settings-language") ]
            , ul [] (List.map languageRadio profiling.languages)
            ]
        ]
