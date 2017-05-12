module Data.Profiling.Input exposing (..)

import Json.Encode as Encode
import Data.Language as Language exposing (Language)
import InputField


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
