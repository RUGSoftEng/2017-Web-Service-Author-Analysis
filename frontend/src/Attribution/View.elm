module Attribution.View exposing (view)

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
import RemoteData exposing (RemoteData(..), WebData)


--

import InputField
import PlotSlideShow
import ViewHelpers
import Attribution.Types exposing (..)
import Attribution.Plots as Plots


view : Model -> Html Msg
view attribution =
    editor attribution



{-
   div []
       [ Grid.container []
           ([ Grid.row [ Row.topXs ]
               [ knownAuthorInput attribution.knownAuthor
               , Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ] []
               , unknownAuthorInput attribution.unknownAuthor
               ]
            ]
               ++ settings attribution
               ++ viewResult attribution.plotState attribution.result
           )
       ]

-}


editor attribution =
    div [ class "content" ]
        [ Grid.container []
            [ Grid.row [ Row.topXs ]
                [ Grid.col []
                    [ h1 [] [ text "Attribution" ]
                    , span [ class "explanation" ]
                        [ text "The Authorship Attribution System will, given one or more texts of which it is known that they are written by the same author, "
                        , text "predict whether a new, "
                        , i [] [ text "unknown" ]
                        , text " text is also written by the same person."
                        ]
                    ]
                ]
            , Grid.row [ Row.attrs [ class "boxes" ] ]
                [ knownAuthorInput attribution.knownAuthor
                , unknownAuthorInput attribution.unknownAuthor
                ]
            , Grid.row []
                [ Grid.col [ Col.attrs [ class "text-center" ] ]
                    [ Button.button [ Button.primary, Button.attrs [ onClick PerformAttribution, id "compare-button" ] ] [ text "Compare!" ]
                    ]
                ]
            , Grid.row [ Row.attrs [ class "boxes settings" ] ] (settings attribution)
            ]
        ]


knownAuthorInput : InputField.Model -> Grid.Column Msg
knownAuthorInput knownAuthor =
    let
        {- config for an InputField

           * label: UI name for this field
           * radioButtonName: internal `name` attribute for the radio buttons
           * fileInputId: id for the <input> element where files for this InputField are stored
           * multiple: can multiple files be uploaded at once
        -}
        config : InputField.ViewConfig
        config =
            { label = "Known Author"
            , radioButtonName = "attribution-known-author-buttons"
            , fileInputId = "attribution-known-author-file-input"
            , info = "Place here the texts of which the author is known. The text can either be pasted directly, or one or more files can be uploaded."
            , multiple = True
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center box" ] ] <|
            (InputField.view config knownAuthor
                |> List.map (Html.map (InputFieldMsg KnownAuthor))
            )


unknownAuthorInput : InputField.Model -> Grid.Column Msg
unknownAuthorInput unknownAuthor =
    let
        config : InputField.ViewConfig
        config =
            { label = "Unknown Author"
            , radioButtonName = "attribution-unknown-author-buttons"
            , fileInputId = "attribution-unknown-author-file-input"
            , info = "Place here the text of which the author is unknown. The text can either be pasted directly, or one file can be uploaded."
            , multiple = False
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center box" ] ] <|
            (InputField.view config unknownAuthor
                |> List.map (Html.map (InputFieldMsg UnknownAuthor))
            )


settings : Model -> List (Grid.Column Msg)
settings attribution =
    let
        languageRadio language =
            li []
                [ label []
                    [ input
                        [ type_ "radio"
                        , checked (language == attribution.language)
                        , onClick (SetLanguage language)
                        ]
                        []
                    , text (toString language)
                    ]
                ]

        featureSetRadio set =
            li []
                [ label []
                    [ input
                        [ type_ "radio"
                        , checked (set == attribution.featureCombo)
                        , onClick (SetFeatureCombo set)
                        ]
                        []
                    , text (toString set)
                    ]
                ]

        genreRadio genre =
            li []
                [ label []
                    [ input
                        [ type_ "radio"
                        , checked False
                          -- , onClick (SetLanguage language)
                        ]
                        []
                    , text genre
                    ]
                ]
    in
        [ Grid.col [ Col.attrs [ class "text-center box" ] ]
            [ h2 [] [ text "Language" ]
            , span [] [ text "Select the language in which all texts are written" ]
            , ul [] (List.map languageRadio attribution.languages)
            ]
        , Grid.col [ Col.attrs [ class "text-center box" ] ]
            [ h2 [] [ text "Genre" ]
            , span [] [ text "Select the genre of the text" ]
            , ul [] (List.map genreRadio [ "Novel", "Tweet", "E-mail" ])
            ]
        , Grid.col [ Col.attrs [ class "text-center box" ] ]
            [ h2 [] [ text "Feature Set" ]
            , span [] [ text "Select the feature combination." ]
            , ul [] (List.map featureSetRadio attribution.featureCombos)
            ]
        ]


{-| Displays the confidence (as a progress bar) and the PlotSlideShow if there is data to be displayed
-}
viewResult : PlotSlideShow.State -> WebData ( Float, Plots.Statistics ) -> List (Html Msg)
viewResult plotState result =
    case result of
        Success ( confidence, statistics ) ->
            [ Grid.row []
                [ Grid.col [ Col.attrs [ class "text-center" ] ]
                    [ h2 []
                        [ hr [] []
                        , text "Results"
                        , hr [] []
                        ]
                    ]
                ]
            , Grid.row []
                [ Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                    [ Progress.progress [ Progress.value (floor <| confidence * 100) ]
                    , h4 [ style [ ( "margin-top", "20px" ) ] ] [ text <| "Same author confidence: " ++ toString (round <| confidence * 100) ++ "%" ]
                    , hr [] []
                    ]
                ]
            , Grid.row []
                [ Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                    [ PlotSlideShow.view plotConfig plotState statistics ]
                ]
            ]

        Failure err ->
            [ text (toString err)
            ]

        _ ->
            []


featureComboToLabel : FeatureCombo -> String
featureComboToLabel combo =
    case combo of
        Combo1 ->
            "shallow"

        Combo4 ->
            "deep"


{-| Config for plots
* plots: what plots to display
* toMsg: how to wrap messages emitted by the PlotSlideShow
-}
plotConfig : PlotSlideShow.Config Plots.Statistics Msg
plotConfig =
    PlotSlideShow.config
        { plots = Plots.plots
        , toMsg = PlotSlideShowMsg
        }
