module Data.Attribution.Prediction exposing (..)

import Json.Decode as Decode exposing (Decoder, float)
import Json.Decode.Pipeline exposing (required)
import Attribution.Plots
import Data.Attribution.Statistics as Statistics exposing (Statistics)


{-| Response from the server

Example JSON:
{ "sameAuthor": true, "confidence": 0.67 }

-}
type alias Prediction =
    { confidence : Float
    , statistics : Statistics
    }


decoder : Decoder Prediction
decoder =
    Decode.succeed Prediction
        |> required "sameAuthorConfidence" float
        |> required "statistics" Statistics.decoder
