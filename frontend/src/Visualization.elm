module Visualization exposing (..)

import Html
import Types exposing (..)
import Json.Decode as Decode
import Plot exposing (..)
import Dict exposing (Dict)


data =
    let
        getters =
            [ (\v -> v / 100) << .characters
            , .lines
            , .blocks
            , .uppers
            , (\v -> v / 100) << .lowers
            ]
    in
        List.map (\getter -> [ getter example.known, getter example.unknown ]) getters


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


bars : Maybe Point -> Bars (List (List Float)) msg
bars hovering =
    groups (List.map2 (hintGroup hovering) [ "100 characters", "lines", "paragraphs", "uppercase", "100 lowercase" ])


view : Maybe Point -> Html.Html msg
view hovering =
    Html.div []
        [ viewBarsCustom defaultBarsPlotCustomizations (bars hovering) data
        ]


example =
    case Decode.decodeString decodeStatistics exampleStatisticsJson of
        Err e ->
            Debug.crash e

        Ok v ->
            v


exampleStatisticsJson =
    """
{
    "unknown": {
        "blocks": 13,
        "lineEndings": {
            ",": 18,
            "?": 3,
            ";": 8,
            ".": 6,
            "!": 13,
            " ": 0,
            "-": 2
        },
        "lines": 74,
        "punctuation": {
            ",": 35,
            "?": 3,
            ";": 8,
            "'": 13,
            ":": 2,
            "!": 13,
            ".": 6,
            "-": 9
        },
        "sentencesFull": 23,
        "words": 445,
        "blockChars": 3019,
        "blank_lines": 0,
        "sentences": 60,
        "blockLines": 62,
        "characters": 3043,
        "lowers": 1555,
        "uppers": 74
    },
    "known": {
        "blocks": 17,
        "lineEndings": {
            ",": 1,
            "?": 9,
            ";": 0,
            ".": 8,
            "!": 0,
            " ": 0,
            "-": 0
        },
        "lines": 52,
        "punctuation": {
            ".": 22,
            "!": 1,
            "-": 0,
            ",": 26,
            "?": 11,
            ";": 3,
            "'": 21,
            ":": 0
        },
        "sentencesFull": 34,
        "words": 405,
        "blockChars": 1667,
        "blank_lines": 0,
        "sentences": 52,
        "blockLines": 36,
        "characters": 1699,
        "lowers": 1193,
        "uppers": 84
    }
}
"""
