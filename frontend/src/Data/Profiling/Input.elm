module Data.Profiling.Input exposing (..)

import Json.Decode as Decode exposing (Decoder, string, bool, int, float, dict)
import Json.Decode.Pipeline as Decode exposing (..)
import Json.Encode as Encode


type alias Input =
    { text : InputField.Model
    }


encoder : Input -> Encode.Value
encoder { text } =
    Encode.object [ ( "text", InputField.encodeModel text ) ]
