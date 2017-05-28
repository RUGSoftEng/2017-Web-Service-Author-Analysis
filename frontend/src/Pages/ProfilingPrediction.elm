module Pages.ProfilingPrediction exposing (..)

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

import Config.Profiling.Plots as Plots
import Data.Profiling.Input as Profiling exposing (..)
import Data.Profiling.Prediction exposing (AgePrediction, GenderPrediction)
import Request.Profiling
import PlotSlideShow


type alias Msg =
    PlotSlideShow.Msg


type alias Model =
    { age : AgePrediction
    , gender : GenderPrediction
    , plotState : PlotSlideShow.State
    , source : Profiling.Input
    }


update : Msg -> Model -> Model
update message model =
    { model | plotState = PlotSlideShow.update message model.plotState }


{-| Displays the confidence (as a progress bar) and the PlotSlideShow if there is data to be displayed
-}
init : Profiling.Input -> Task Http.Error Model
init input =
    let
        plotState =
            case Dict.keys Plots.profilingPlot of
                [] ->
                    -- TODO make this safe
                    Debug.crash "No plots to be displayed"

                x :: xs ->
                    PlotSlideShow.initialState x xs

        loadPrediction =
            Request.Profiling.get input
                |> Http.toTask
    in
        Task.map (\{ age, gender } -> Model age gender plotState input) loadPrediction


view : Model -> Html Msg
view model =
    Grid.container [] (viewResult model)


viewResult : Model -> List (Html Msg)
viewResult { age, gender, plotState } =
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
            [ Progress.progress [ Progress.value (floor <| gender.male * 100) ]
            , h4 [ style [ ( "margin-top", "20px" ) ] ] [ text <| "Same author confidence: " ++ toString (round <| gender.male * 100) ++ "%" ]
            , hr [] []
            ]
        ]
    , Grid.row []
        [ Grid.col [ Col.attrs [ class "center-block text-center" ] ]
            [ PlotSlideShow.view plotConfig plotState age ]
        ]
    ]


{-| Config for plots
* plots: what plots to display
* toMsg: how to wrap messages emitted by the PlotSlideShow
-}
plotConfig : PlotSlideShow.Config AgePrediction PlotSlideShow.Msg
plotConfig =
    PlotSlideShow.config
        { plots = Plots.profilingPlot
        , toMsg = identity
        }
