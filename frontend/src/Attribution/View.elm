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
import RemoteData exposing (RemoteData(..))


--

import InputField
import PlotSlideShow
import ViewHelpers
import Attribution.Types exposing (..)
import Attribution.Plots as Plots


view : Model -> Html Msg
view attribution =
    let
        knownAuthorInput =
            let
                config =
                    { label =
                        "Known Author"
                        -- the `name` attribute for radio buttons
                    , radioButtonName =
                        "attribution-known-author-buttons"
                        -- the id for the <input> element where the files are stored
                    , fileInputId =
                        "attribution-known-author-file-input"
                        -- allow multiple files to be selected
                    , multiple = True
                    }
            in
                Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                    (InputField.view attribution.knownAuthor config
                        |> List.map (Html.map (AttributionInputField KnownAuthor))
                    )

        unknownAuthorInput =
            let
                config =
                    { label = "Unknown Author"
                    , radioButtonName = "attribution-unknown-author-buttons"
                    , fileInputId = "attribution-unknown-author-file-input"
                    , multiple = False
                    }
            in
                Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                    (InputField.view attribution.unknownAuthor config
                        |> List.map (Html.map (AttributionInputField UnknownAuthor))
                    )

        plotConfig : PlotSlideShow.Config Plots.Statistics Msg
        plotConfig =
            PlotSlideShow.config
                { plots = Plots.plots
                , toMsg = AttributionStatisticsMsg
                }

        result =
            case attribution.result of
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
                            [ PlotSlideShow.view plotConfig attribution.plotState statistics ]
                        ]
                    ]

                _ ->
                    []

        separator =
            Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ]
                []
    in
        div []
            [ ViewHelpers.jumbotron "Author Recognition" "Predict whether two texts are written by the same author"
            , Grid.container []
                ([ Grid.row [ Row.topXs ]
                    [ knownAuthorInput
                    , separator
                    , unknownAuthorInput
                    ]
                 , Grid.row []
                    [ Grid.col [ Col.attrs [ class "text-center" ] ]
                        [ Button.button [ Button.primary, Button.attrs [ onClick PerformAttribution, id "compare-button" ] ] [ text "Compare!" ]
                        ]
                    ]
                 , Grid.row []
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
                        , ViewHelpers.languageSelector "attribution-language" SetLanguage attribution.languages attribution.language
                        ]
                    , Grid.col [ Col.attrs [ class "text-center" ] ]
                        [ h3 [] [ text "feature combination" ]
                        , let
                            toLabel combo =
                                case combo of
                                    Combo1 ->
                                        "shallow"

                                    Combo4 ->
                                        "deep"
                          in
                            ViewHelpers.featureComboSelector "attribution-feature-combo" SetFeatureCombo toLabel attribution.featureCombos attribution.featureCombo
                        ]
                    ]
                 ]
                    ++ result
                )
            ]
