module Attribution.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder)
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
    div []
        [ ViewHelpers.jumbotron "Author Recognition" "Predict whether two texts are written by the same author"
        , Grid.container []
            ([ Grid.row [ Row.topXs ]
                [ knownAuthorInput attribution.knownAuthor
                , Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ] []
                , unknownAuthorInput attribution.unknownAuthor
                ]
             , Grid.row []
                [ Grid.col [ Col.attrs [ class "text-center" ] ]
                    [ Button.button [ Button.primary, Button.attrs [ onClick PerformAttribution, id "compare-button" ] ] [ text "Compare!" ]
                    ]
                ]
             ]
                ++ settings attribution
                ++ viewResult attribution.plotState attribution.result
            )
        ]


knownAuthorInput : InputField.State -> Grid.Column Msg
knownAuthorInput knownAuthor =
    let
        {- config for an InputField

           * label: UI name for this field
           * radioButtonName: internal `name` attribute for the radio buttons
           * fileInputId: id for the <input> element where files for this InputField are stored
           * multiple: can multiple files be uploaded at once
        -}
        config =
            { label = "Known Author"
            , radioButtonName = "attribution-known-author-buttons"
            , fileInputId = "attribution-known-author-file-input"
            , multiple = True
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
            (InputField.view knownAuthor config
                |> List.map (Html.map (InputFieldMsg KnownAuthor))
            )


unknownAuthorInput : InputField.State -> Grid.Column Msg
unknownAuthorInput unknownAuthor =
    let
        config =
            { label = "Unknown Author"
            , radioButtonName = "attribution-unknown-author-buttons"
            , fileInputId = "attribution-unknown-author-file-input"
            , multiple = False
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
            (InputField.view unknownAuthor config
                |> List.map (Html.map (InputFieldMsg UnknownAuthor))
            )


settings : Model -> List (Html Msg)
settings attribution =
    [ Grid.row []
        [ Grid.col [ Col.attrs [ class "text-center" ] ]
            [ h2 []
                [ hr [] []
                , text "Settings"
                , hr [] []
                ]
            ]
        ]
    , Grid.row []
        [ Grid.col [ Col.attrs [ class "text-center" ] ]
            [ h3 [] [ text "language" ]
            , ViewHelpers.languageSelector "attribution-language"
                SetLanguage
                attribution.languages
                attribution.language
            ]
        , Grid.col [ Col.attrs [ class "text-center" ] ]
            [ h3 [] [ text "feature combination" ]
            , ViewHelpers.featureComboSelector "attribution-feature-combo"
                SetFeatureCombo
                featureComboToLabel
                attribution.featureCombos
                attribution.featureCombo
            ]
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
