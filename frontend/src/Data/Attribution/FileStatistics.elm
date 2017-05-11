module Data.Attribution.FileStatistics exposing (..)

import Json.Decode as Decode exposing (Decoder, string, int, float)
import Json.Decode.Pipeline as Decode exposing (decode, required)
import Data.Helpers exposing (dictBoth)
import String
import Dict exposing (Dict)


type alias FileStatistics =
    { characters : Float
    , lines : Float
    , blocks : Float
    , uppers : Float
    , lowers : Float
    , punctuation : Dict Char Float
    , lineEndings : Dict Char Float
    , sentences : Float
    , words : Float
    }


decoder : Decoder FileStatistics
decoder =
    let
        stringToChar str =
            case String.uncons str of
                Just ( c, rest ) ->
                    if rest == "" then
                        Ok c
                    else
                        Err <| "trying to decode a single Char, but got `" ++ str ++ "`"

                Nothing ->
                    Err <| "decoding a char failed: no input"
    in
        decode FileStatistics
            |> required "characters" float
            |> required "lines" float
            |> required "blocks" float
            |> required "uppers" float
            |> required "lowers" float
            |> required "lineEndings" (dictBoth stringToChar float)
            |> required "punctuation" (dictBoth stringToChar float)
            |> required "sentences" float
            |> required "words" float
