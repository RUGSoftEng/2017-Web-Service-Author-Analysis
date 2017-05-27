module Data.Profiling.Prediction exposing (..)

import Json.Decode as Decode exposing (Decoder, float)
import Json.Decode.Pipeline exposing (required)
import String


type alias Prediction =
    { age : AgePrediction, gender : GenderPrediction }


type alias AgePrediction =
    { range18_24 : Float
    , range25_34 : Float
    , range35_49 : Float
    , range50_64 : Float
    , range65_xx : Float
    }


type alias GenderPrediction =
    { male : Float, female : Float }


decodeAgePrediction : Decoder AgePrediction
decodeAgePrediction =
    Decode.succeed AgePrediction
        |> required "18-24" float
        |> required "25-34" float
        |> required "35-49" float
        |> required "50-64" float
        |> required "65-xx" float


decodeGenderPrediction : Decoder GenderPrediction
decodeGenderPrediction =
    Decode.succeed GenderPrediction
        |> required "Male" float
        |> required "Female" float


decoder : Decoder Prediction
decoder =
    Decode.succeed Prediction
        |> required "Age groups" decodeAgePrediction
        |> required "Genders" decodeGenderPrediction
