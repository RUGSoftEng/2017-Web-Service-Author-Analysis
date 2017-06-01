module Pages.AttributionPrediction exposing (..)

import Dict
import Http
import Task exposing (Task)


--

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder, checked)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Progress as Progress


--

import Config.Attribution.Plots as Plots
import I18n exposing (Translator)
import Data.Attribution.Input as Attribution exposing (..)
import Data.Attribution.Statistics exposing (Statistics)
import Request.Attribution
import PlotSlideShow


type alias Msg =
    PlotSlideShow.Msg


type alias Model =
    { confidence : Float
    , statistics : Statistics
    , plotState : PlotSlideShow.State
    , source : Attribution.Input
    }


update : PlotSlideShow.Msg -> Model -> Model
update plotMessage model =
    { model | plotState = PlotSlideShow.update plotMessage model.plotState }


{-| Displays the confidence (as a progress bar) and the PlotSlideShow if there is data to be displayed
-}
init : Input -> Task Http.Error Model
init input =
    let
        plotState =
            case Dict.keys Plots.plots of
                [] ->
                    -- TODO make this safe
                    Debug.crash "No plots to be displayed"

                x :: xs ->
                    PlotSlideShow.initialState x xs

        loadPrediction =
            Request.Attribution.get input
                |> Http.toTask
    in
        Task.map (\{ confidence, statistics } -> Model confidence statistics plotState input) loadPrediction


view : Translator -> Model -> Html Msg
view t model =
    div [ class "content" ]
        [ Grid.container [] (viewResult t model)
        ]


viewResult : Translator -> Model -> List (Html PlotSlideShow.Msg)
viewResult t { plotState, confidence, statistics } =
    let
        plotConfig : PlotSlideShow.Config Statistics PlotSlideShow.Msg
        plotConfig =
            PlotSlideShow.config
                { plots = Plots.plots
                , toMsg = identity
                , t = t
                }
    in
        [ Grid.row []
            [ Grid.col []
                [ h1 [] [ text (t "title") ]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                [ Progress.progress [ Progress.value (floor <| confidence * 100) ]
                , h4 [ style [ ( "margin-top", "20px" ) ] ] [ text <| (t "same-author-confidence") ++ ": " ++ toString (round <| confidence * 100) ++ "%" ]
                , hr [] []
                ]
            ]
        , Grid.row [] [ Grid.col [] [ h3 [] [ text (t "document-analysis") ] ] ]
        , Grid.row []
            [ Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                [ PlotSlideShow.view plotConfig plotState statistics ]
            ]
        ]


featureComboToLabel : FeatureCombo -> String
featureComboToLabel combo =
    case combo of
        Combo1 ->
            "shallow"

        Combo4 ->
            "deep"
