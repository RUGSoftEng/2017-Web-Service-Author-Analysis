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


warnings : String -> Result (List String) ()
warnings str =
    let
        tooShort =
            { validator = \str -> String.length str > 40
            , message = "Your input is a little short, try adding some more for better predictions"
            }

        tooLong =
            { validator = \str -> String.length str < 1000
            , message = "Your input is very long. The profiling works best on smaller inputs"
            }

        checks =
            [ tooShort, tooLong ]
    in
        List.map (boolCheck str) checks
            |> combineErrors


errors : String -> Result (List String) ()
errors str =
    let
        isNotEmpty =
            { validator = not << String.isEmpty
            , message = "The system needs text to analyze. Please give it some"
            }

        oneLetter =
            { validator = String.any (\c -> Char.isLower c || Char.isUpper c)
            , message = "The system needs letters to do a prediction. Please give it some"
            }

        checks =
            [ isNotEmpty
            , oneLetter
            ]
    in
        List.map (boolCheck str) checks
            |> combineErrors
