module Visualization exposing (..)

import Html
import Types exposing (..)
import Json.Decode as Decode
import Plot exposing (..)
import Dict exposing (Dict)


data =
    let
        getters =
            [ (\v -> v // 100) << .characters
            , .lines
            , .blocks
            , .uppers
            , (\v -> v // 100) << .lowers
            ]
    in
        List.map (\getter -> [ toFloat <| getter example.known, toFloat <| getter example.unknown ]) getters


plotPunctuation : Statistics -> Html.Html msg
plotPunctuation { known, unknown } =
    Dict.toList known.punctuation
        |> List.map2 (\v2 ( k, v ) -> ( k, [ v, v2 ] )) (Dict.values unknown.punctuation)
        |> viewBars (groups (List.map (\( key, value ) -> group (String.fromChar key) (List.map toFloat value))))


plotLineEndings : Statistics -> Html.Html msg
plotLineEndings { known, unknown } =
    Dict.toList known.lineEndings
        |> List.map2 (\v2 ( k, v ) -> ( k, [ v, v2 ] )) (Dict.values unknown.lineEndings)
        |> viewBars (groups (List.map (\( key, value ) -> group (String.fromChar key) (List.map toFloat value))))


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
