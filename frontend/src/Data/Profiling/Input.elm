module Data.Profiling.Input exposing (..)

import Json.Encode as Encode
import Char
import Data.TextInput as TextInput
import Data.Language as Language exposing (Language)
import Data.Validation exposing (Validation, boolCheck, combineErrors)
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


validate : String -> Validation
validate =
    Data.Validation.validate { errors = errors, warnings = warnings }


warnings : List (String -> Maybe String)
warnings =
    let
        tooShort s =
            if String.length s < 40 then
                Just "Your input is a little short, try adding some more for better predictions"
            else
                Nothing
    in
        [ tooShort ]


errors : List (String -> Maybe String)
errors =
    let
        isNotEmpty s =
            if String.isEmpty s then
                Just "The system needs text to analyze. Please give it some"
            else
                Nothing

        oneLetter s =
            if not <| String.any (\c -> Char.isLower c || Char.isUpper c) s then
                Just "The system needs letters to do a prediction. Please give it some"
            else
                Nothing
    in
        [ isNotEmpty
        , oneLetter
        ]
