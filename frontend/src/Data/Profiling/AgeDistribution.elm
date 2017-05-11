module Data.Profiling.AgeDistribution exposing (..)

import Json.Decode as Decode exposing (Decoder, list, float)


type alias AgeDistribution =
    { between18and24 : Float
    , between24and34 : Float
    , between35and49 : Float
    , between50and64 : Float
    , between65andHigher : Float
    }


toList : AgeDistribution -> List Float
toList { between18and24, between24and34, between35and49, between50and64, between65andHigher } =
    [ between18and24, between24and34, between35and49, between50and64, between65andHigher ]


decoder : Decoder AgeDistribution
decoder =
    list float
        |> Decode.andThen
            (\strings ->
                case strings of
                    [ a, b, c, d, e ] ->
                        Decode.succeed (AgeDistribution a b c d e)

                    _ ->
                        Decode.fail "incorrect number of float values for age distribution"
            )
