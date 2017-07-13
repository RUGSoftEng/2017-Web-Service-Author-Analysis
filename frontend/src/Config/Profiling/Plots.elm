module Config.Profiling.Plots exposing (profilingPlot)

{-| Similar to Config.Attribution.Plots
-}

import Html exposing (text, div)
import Plot exposing (group, viewBarsCustom, defaultBarsPlotCustomizations, BarGroup, MaxBarWidth(Percentage), Bars, normalAxis)
import Svg.Attributes exposing (fill)
import Dict exposing (Dict)
import PlotSlideShow exposing (Plot)
import Data.Profiling.Prediction exposing (AgePrediction, GenderPrediction)


profilingPlot : Dict String (Plot AgePrediction msg)
profilingPlot =
    let
        data =
            [ { id = "age-distribution"
              , render = plotAges
              }
            ]
    in
        List.map (\datum -> ( datum.id, PlotSlideShow.plot datum )) data
            |> Dict.fromList


customizations : Plot.PlotCustomizations msg
customizations =
    { defaultBarsPlotCustomizations | margin = { top = 20, right = 40, bottom = 40, left = 50 } }


groups : (data -> List BarGroup) -> Bars data msg
groups toGroups =
    let
        pinkFill =
            "rgba(253, 185, 231, 0.5)"

        lightBlueFill =
            "#e4eeff"

        blueFill =
            "#5285ff"

        redFill =
            "#f45e5a"
    in
        { axis = normalAxis
        , toGroups = toGroups
        , styles = [ [ fill redFill ], [ fill blueFill ] ]
        , maxWidth = Percentage 75
        }


plotAges : AgePrediction -> Html.Html msg
plotAges age =
    let
        data =
            [ ( "18 to 24", [ age.range18_24 ] )
            , ( "25 to 34", [ age.range25_34 ] )
            , ( "35 to 49", [ age.range35_49 ] )
            , ( "50 to 64", [ age.range50_64 ] )
            , ( "over 64", [ age.range65_xx ] )
            ]
    in
        viewBarsCustom customizations (groups (List.map (\( label, value ) -> group label value))) data
