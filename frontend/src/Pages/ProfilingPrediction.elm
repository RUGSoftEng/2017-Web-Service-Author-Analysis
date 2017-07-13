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
import I18n exposing (Translator)
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


view : Translator -> Model -> Html Msg
view t model =
    div [ class "content" ]
        [ Grid.container [] (viewResult t model)
        ]


viewResult : Translator -> Model -> List (Html Msg)
viewResult t { age, gender, plotState } =
    let
        plotConfig : PlotSlideShow.Config AgePrediction PlotSlideShow.Msg
        plotConfig =
            PlotSlideShow.config
                { plots = Plots.profilingPlot
                , toMsg = identity
                , t = t
                }
    in
        [ Grid.row []
            [ Grid.col [ Col.attrs [] ]
                [ h1 []
                    [ text (t "title") ]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.attrs [ class "text-center" ] ]
                [ h2 []
                    [ hr [] []
                    , text (t "gender")
                    ]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                [ Progress.progress [ Progress.value (floor <| gender.male * 100) ]
                , h4 [ style [ ( "margin-top", "20px" ) ] ]
                    [ text <| "Male probability: " ++ toString (round <| gender.male * 100) ++ "%" ++ " vs Female probability: " ++ toString (round <| gender.female * 100) ++ "%" ]
                , hr [] []
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.attrs [ class "text-center" ] ]
                [ h2 []
                    [ text (t "plots") ]
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                [ PlotSlideShow.view plotConfig plotState age ]
            ]
        ]
