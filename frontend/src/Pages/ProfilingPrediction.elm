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

import Data.Profiling.Input as Profiling exposing (..)
import Data.Profiling.Prediction exposing (AgePrediction, GenderPrediction)
import Request.Profiling
import PlotSlideShow


type alias Msg =
    ()


type alias Model =
    { age : AgePrediction
    , gender : GenderPrediction
    , source : Profiling.Input
    }


update : Msg -> Model -> Model
update () model =
    model


{-| Displays the confidence (as a progress bar) and the PlotSlideShow if there is data to be displayed
-}
init : Profiling.Input -> Task Http.Error Model
init input =
    let
        loadPrediction =
            Request.Profiling.get input
                |> Http.toTask
    in
        Task.map (\{ age, gender } -> Model age gender input) loadPrediction


view : Model -> Html Msg
view model =
    Grid.container [] (viewResult model)


viewResult : Model -> List (Html Msg)
viewResult { age, gender } =
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
            []
        ]
    ]
