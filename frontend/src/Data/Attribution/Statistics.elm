module Data.Attribution.Statistics exposing (..)

import Json.Decode as Decode exposing (Decoder, string, int, float)
import Json.Decode.Pipeline as Decode exposing (decode, required)
import Dict exposing (Dict)
import Data.Attribution.FileStatistics as FileStatistics exposing (FileStatistics)
import Data.Helpers exposing (dictBoth)


type alias Statistics =
    { known : FileStatistics
    , unknown : FileStatistics
    , ngramsSim : Dict Int Float
    , ngramsSpi : Dict Int Int
    , similarity : Dict String Float
    }


decoder : Decoder Statistics
decoder =
    Decode.succeed Statistics
        |> required "known" FileStatistics.decoder
        |> required "unknown" FileStatistics.decoder
        |> required "ngrams-sim" (dictBoth (Decode.decodeString int) float)
        |> required "ngrams-spi" (dictBoth (Decode.decodeString int) int)
        |> required "similarities" (Decode.dict float)
