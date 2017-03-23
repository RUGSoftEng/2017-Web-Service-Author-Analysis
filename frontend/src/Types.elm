module Types exposing (..)

{-| The types used in the application, importantly

* Model, our model of the world
* Msg, all the actions the app can perform

These are in a separate file because they need to be imported in multiple files. Any other place
for the types would lead to circular dependencies.
-}

import Bootstrap.Navbar as Navbar
import Navigation
import Json.Decode as Decode exposing (string, bool, int, float)
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
    { sameAuthor : Bool, confidence : Float }


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
        [ "text" => InputField.encodeFirstFile profiling.text
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
