module Data.Profiling.Input exposing (..)

import Json.Encode as Encode
import Data.TextInput as TextInput
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
        [ ( "text", TextInput.firstFileEncoder text.input )
        , ( "language", Language.encoder language )
        ]
