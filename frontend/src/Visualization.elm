module Visualization exposing (..)

import Html
import Types exposing (..)
import Json.Decode as Decode
import Plot exposing (..)
import Dict exposing (Dict)


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


example =
    case Decode.decodeString decodeStatistics exampleStatisticsJson of
        Err e ->
            Debug.crash e

        Ok v ->
            v


exampleStatisticsJson =
    """{"ngrams-spi": {"1": 48.0, "2": 58.0, "3": 26.0, "4": 11.0, "5": 2.0}, "known": {"blocks": 17, "words": 405, "lowers": 1193, "lines": 52, "sentencesFull": 34, "blank_lines": 0, "punctuation": {":": 0, "?": 11, ".": 22, ";": 3, "'": 21, ",": 26, "-": 0, "!": 1}, "blockLines": 36, "lineEndings": {";": 0, "?": 9, ".": 8, " ": 0, ",": 1, "-": 0, "!": 0}, "characters": 1699, "blockChars": 1667, "sentences": 52, "uppers": 84}, "unknown": {"blocks": 13, "words": 445, "lowers": 1555, "lines": 74, "sentencesFull": 23, "blank_lines": 0, "punctuation": {":": 2, "?": 3, ";": 8, ".": 6, ",": 35, "'": 13, "-": 9, "!": 13}, "blockLines": 62, "lineEndings": {";": 8, "?": 3, ".": 6, " ": 0, ",": 18, "-": 2, "!": 13}, "characters": 3043, "blockChars": 3019, "sentences": 60, "uppers": 74}, "combined": null, "ngrams-sim": {"1": 72.60479167424606, "2": 173.75137512997733, "3": 419.69457521709506, "4": 601.1759227430915, "5": 3698.6489727722796}}
"""
