module Data.Profiling.Prediction exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import String
import Data.Profiling.AgeDistribution as AgeDistribution exposing (AgeDistribution)


type alias Prediction =
    { ageDistribution : AgeDistribution, gender : Gender }


type Gender
    = M
    | F


decodeGender : Decoder Gender
decodeGender =
    Decode.string
        |> Decode.andThen
            (\gender ->
                case String.toLower gender of
                    "female" ->
                        Decode.succeed F

                    "male" ->
                        Decode.succeed M

                    _ ->
                        Decode.fail ("could not decode `" ++ gender ++ "` to a gender")
            )


decoder : Decoder Prediction
decoder =
    Decode.succeed Prediction
        |> required "age_distribution" AgeDistribution.decoder
        |> required "gender" decodeGender
