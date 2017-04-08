module Visualization exposing (..)

{-| Describes how we want to draw our plots (and which ones to draw)

Most of the heavy lifting is actually done by PlotSlideShow, which
will keep track of which plot has focus and how the title and description
are laid out around the plot.
-}

import Html exposing (text)
import Json.Decode as Decode
import Plot exposing (..)
import Dict exposing (Dict)
import Types exposing (Statistics, FileStatistics)
import PlotSlideShow exposing (Plot)


plots : Dict String (Plot Statistics msg)
plots =
    let
        data =
            [ { label = "punctuation"
              , title = "punctuation per character"
              , render = plotPunctuation
              , description = text "The usage of punctuation is indicative of the author based on ... "
              }
            , { label = "line endings"
              , title = "line endings per character"
              , render = plotLineEndings
              , description = text "The usage of line endings is indicative of the author based on ... "
              }
            , { label = "anagram SIM"
              , title = "anagram similarity"
              , render = plotNgramsSim
              , description = text "anagram similarity measures ... "
              }
            , { label = "anagram SPI"
              , title = "anagram SPI"
              , render = plotNgramsSpi
              , description = text "anagram spi measures ... "
              }
            ]
    in
        List.map (\datum -> ( datum.label, PlotSlideShow.plot datum )) data
            |> Dict.fromList


plotAverages : Statistics -> Html.Html msg
plotAverages { known, unknown } =
    let
        data =
            [ ( "sentence length", [ known.sentences / known.lines, unknown.sentences / unknown.lines ] )
            , ( "words per line", [ known.words / known.lines, unknown.words, unknown.lines ] )
              -- , ( "lines per paragraph", [ known.blockLines / known.blocks, unknown.blockLines / unknown.blocks ] )
              -- , ("uppercase per lowercase", [ known.uppers / known.lowers, unknown.uppers / unknown.lowers ]
            ]
    in
        viewBars (groups (List.map (\( label, value ) -> group label value))) data


plotPunctuation : Statistics -> Html.Html msg
plotPunctuation { known, unknown } =
    let
        construct ( label, v1 ) ( _, v2 ) =
            ( String.fromChar label, [ v1 / known.characters, v2 / known.characters ] )
    in
        List.map2 construct (Dict.toList known.punctuation) (Dict.toList unknown.punctuation)
            |> viewBars (groups (List.map (uncurry group)))


plotLineEndings : Statistics -> Html.Html msg
plotLineEndings { known, unknown } =
    let
        construct ( label, v1 ) ( _, v2 ) =
            ( String.fromChar label, [ v1 / known.lines, v2 / known.lines ] )
    in
        List.map2 construct (Dict.toList known.lineEndings) (Dict.toList unknown.lineEndings)
            |> viewBars (groups (List.map (uncurry group)))


plotNgramsSim : Statistics -> Html.Html msg
plotNgramsSim { ngramsSim } =
    let
        construct ( key, value ) =
            ( toString key, [ value ] )
    in
        ngramsSim
            |> Dict.toList
            |> List.map construct
            |> viewBars (groups (List.map (uncurry group)))


plotNgramsSpi : Statistics -> Html.Html msg
plotNgramsSpi { ngramsSpi } =
    let
        construct ( key, value ) =
            ( toString key, [ toFloat value ] )
    in
        ngramsSpi
            |> Dict.toList
            |> List.map construct
            |> viewBars (groups (List.map (uncurry group)))
