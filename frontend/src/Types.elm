module Types exposing (..)

{-| The types used in the application, importantly

* Model, our model of the world
* Msg, all the actions the app can perform

These are in a separate file because they need to be imported in multiple files. Any other place
for the types would lead to circular dependencies.
-}

import Bootstrap.Navbar as Navbar
import Navigation
import Json.Decode as Decode exposing (string, bool, int, float, dict)
import Json.Decode.Pipeline as Decode exposing (..)
import Json.Encode as Encode
import Dict exposing (Dict)
import Http


--

import InputField


{-| Our model of the world
-}
type alias Model =
    { route : Route
    , navbarState : Navbar.State
    , profiling : ProfilingState
    , attribution : AttributionState
    }


{-| All the actions our application can perform
-}
type Msg
    = NoOp
    | NavbarMsg Navbar.State
    | ChangeRoute Route
    | AttributionMsg AttributionMessage
    | ProfilingMsg ProfilingMessage
    | UrlChange Navigation.Location
    | AddFile ( String, File )


type AttributionMessage
    = SetLanguage Language
    | SetFeatureCombo FeatureCombo
    | PerformAttribution
    | ServerResponse (Result Http.Error AttributionResponse)
    | AttributionInputField Author InputField.Msg


type Author
    = KnownAuthor
    | UnknownAuthor


type ProfilingMessage
    = ProfilingInputField InputField.Msg
    | UploadAuthorProfiling


{-| type alias with the same name.
this is the (only) way to re-export a type
-}
type alias File =
    InputField.File



-- nested structures


type alias AttributionState =
    { knownAuthor : InputField.State
    , unknownAuthor : InputField.State
    , result : Maybe AttributionResponse
    , language : Language
    , languages : List Language
    , featureCombo : FeatureCombo
    , featureCombos : List FeatureCombo
    }


{-| Supported languages
-}
type Language
    = EN
    | NL


type FeatureCombo
    = Combo1
    | Combo4


type alias ProfilingState =
    { input : InputField.State
    , result : Maybe ProfilingResponse
    }


{-| The pages that the application can be on
-}
type Route
    = Home
    | AttributionRoute
    | ProfilingRoute



{-
   Example JSON:
   {"profilingText": "lorem"}

-}


type alias ProfilingRequest =
    { profilingText : String }


{-| Response from the server

Example JSON:
{ "sameAuthor": true, "confidence": 0.67 }

-}
type alias AttributionResponse =
    { confidence : Float }


type alias ProfilingResponse =
    { gender : Gender, age : Int }


type Gender
    = M
    | F


{-| A shorthand for creating a tuple, saves typing parenthises
-}
(=>) : a -> b -> ( a, b )
(=>) =
    (,)


encodeAttributionRequest : AttributionState -> Encode.Value
encodeAttributionRequest attribution =
    let
        featureComboToInt combo =
            case combo of
                Combo1 ->
                    1

                Combo4 ->
                    4
    in
        Encode.object
            [ "knownAuthorTexts" => InputField.encodeState attribution.knownAuthor
            , "unknownAuthorText" => InputField.encodeFirstFile attribution.unknownAuthor
            , "language" => Encode.string (toString attribution.language)
            , "genre" => Encode.int 0
            , "featureSet" => Encode.int (featureComboToInt attribution.featureCombo)
            ]


decodeAttributionResponse : Decode.Decoder AttributionResponse
decodeAttributionResponse =
    Decode.succeed AttributionResponse
        |> required "sameAuthorConfidence" float


encodeProfilingRequest : ProfilingState -> Encode.Value
encodeProfilingRequest profiling =
    Encode.object
        [ "text" => InputField.encodeFirstFile profiling.input
        , "language" => Encode.string (toString EN)
        , "genre " => Encode.int 0
        , "featureSet" => Encode.int 0
        ]


decodeProfilingResponse : Decode.Decoder ProfilingResponse
decodeProfilingResponse =
    Decode.succeed ProfilingResponse
        |> required "gender"
            (string
                |> Decode.andThen
                    (\genderString ->
                        case genderString of
                            "M" ->
                                Decode.succeed M

                            "F" ->
                                Decode.succeed F

                            _ ->
                                Decode.fail <| "cannot convert" ++ genderString ++ "to a gender"
                    )
            )
        |> required "age" int


type alias Statistics =
    { known : FileStatistics
    , unknown : FileStatistics
    }


decodeStatistics =
    Decode.succeed Statistics
        |> required "known" decodeFileStatistics
        |> required "unknown" decodeFileStatistics


type alias FileStatistics =
    { characters : Float
    , lines : Float
    , blocks : Float
    , uppers : Float
    , lowers : Float
    , punctuation : Dict Char Float
    , lineEndings : Dict Char Float
    , sentences : Float
    , words : Float
    }


{-| Convert a dict's keys from string to char
this conversion may fail, so we return a decoder
(a decoder can fail or succeed, so represents the possibility of failure)
-}
keysToChar : Dict String a -> Decode.Decoder (Dict Char a)
keysToChar dict =
    Dict.foldr
        (\key value accum ->
            case String.uncons key of
                Nothing ->
                    Decode.fail "cannot decode empty string to char"

                Just ( char, "" ) ->
                    Decode.map (Dict.insert char value) accum

                Just _ ->
                    Decode.fail <| "expected a single character, but got `" ++ key ++ "`"
        )
        (Decode.succeed Dict.empty)
        dict


decodeFileStatistics =
    decode FileStatistics
        |> required "characters" float
        |> required "lines" float
        |> required "blocks" float
        |> required "uppers" float
        |> required "lowers" float
        |> required "lineEndings" (dict float |> Decode.andThen keysToChar)
        |> required "punctuation" (dict float |> Decode.andThen keysToChar)
        |> required "sentences" float
        |> required "words" float
