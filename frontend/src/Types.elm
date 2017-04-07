module Types exposing (..)

{-| The types used in the application, importantly

* Model, our model of the world
* Msg, all the actions the app can perform

These are in a separate file because they need to be imported in multiple files. Any other place
for the types would lead to circular dependencies.
-}

import Bootstrap.Navbar as Navbar
import Navigation
import Json.Decode as Decode exposing (Decoder, string, bool, int, float, dict)
import Json.Decode.Pipeline as Decode exposing (..)
import Json.Encode as Encode
import Dict exposing (Dict)
import Http
import RemoteData exposing (WebData)


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
    , result : WebData AttributionResponse
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


{-| The feature combo to use

The feature combo determines what characteristics of a text are
used and how strongly they are weighted.
-}
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
    { confidence : Float
    , statistics : Statistics
    }


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
        |> required "statistics" decodeStatistics


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
    , ngramsSim : Dict Int Float
    , ngramsSpi : Dict Int Int
    }


decodeStatistics =
    Decode.succeed Statistics
        |> required "known" decodeFileStatistics
        |> required "unknown" decodeFileStatistics
        |> required "ngrams-sim" (dictBoth (Decode.decodeString int) float)
        |> required "ngrams-spi" (dictBoth (Decode.decodeString int) int)


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


{-| Convert an object into a dictionary with decoded keys AND values.
the builtin dict decoder only allows you to decode values, defaulting keys to String
-}
dictBoth : (String -> Result String comparable) -> Decoder value -> Decoder (Dict comparable value)
dictBoth keyDecoder valueDecoder =
    let
        decodeKeys kvpairs =
            List.foldr decodeKey (Decode.succeed Dict.empty) kvpairs

        decodeKey ( key, value ) accum =
            case keyDecoder key of
                Err e ->
                    Decode.fail <| "decoding a key failed: " ++ e

                Ok newKey ->
                    Decode.map (Dict.insert newKey value) accum
    in
        Decode.keyValuePairs valueDecoder
            |> Decode.andThen decodeKeys


char =
    Decode.string
        |> Decode.andThen
            (\str ->
                case String.uncons str of
                    Just ( c, rest ) ->
                        if rest == "" then
                            Decode.succeed c
                        else
                            Decode.fail <| "trying to decode a single Char, but got `" ++ str ++ "`"

                    Nothing ->
                        Decode.fail <| "decoding a char failed: no input"
            )


decodeFileStatistics =
    let
        stringToChar str =
            case String.uncons str of
                Just ( c, rest ) ->
                    if rest == "" then
                        Ok c
                    else
                        Err <| "trying to decode a single Char, but got `" ++ str ++ "`"

                Nothing ->
                    Err <| "decoding a char failed: no input"
    in
        decode FileStatistics
            |> required "characters" float
            |> required "lines" float
            |> required "blocks" float
            |> required "uppers" float
            |> required "lowers" float
            |> required "lineEndings" (dictBoth stringToChar float)
            |> required "punctuation" (dictBoth stringToChar float)
            |> required "sentences" float
            |> required "words" float
