module Data.Profiling.Input exposing (..)

import Json.Decode as Decode exposing (Decoder, string, bool, int, float, dict)
import Json.Decode.Pipeline as Decode exposing (..)
import Json.Encode as Encode
import InputField
import Data.Language as Language exposing (Language)


type alias Input =
    { text : InputField.Model
    , language : Language
    , languages : List Language
    }


encoder : Input -> Encode.Value
encoder { text, language } =
    Encode.object
        [ ( "text", InputField.encodeModel text )
        , ( "language", Language.encoder language )
        ]
