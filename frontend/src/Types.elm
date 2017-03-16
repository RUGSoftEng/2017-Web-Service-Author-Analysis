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
import Http


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


type AttributionMessage
    = SetLanguage Language
    | ToggleInputMode Author
    | SetText Author String
    | PerformAttribution
    | ServerResponse (Result Http.Error AttributionResponse)


type Author
    = KnownAuthor
    | UnknownAuthor


type ProfilingMessage
    = UploadAuthorProfiling
    | ToggleProfilingInputMode
    | SetProfilingText String



-- nested structures


type alias AttributionState =
    { knownAuthorMode : InputMode
    , knownAuthorText : String
    , unknownAuthorMode : InputMode
    , unknownAuthorText : String
    , result : Maybe AttributionResponse
    , language : Language
    }


{-| Update a wrapped AttributionState

    mapAttribution (\attribution -> { attribution | language = EN }) model
-}
mapAttribution :
    (AttributionState -> AttributionState)
    -> { a | attribution : AttributionState }
    -> { a | attribution : AttributionState }
mapAttribution updater record =
    { record | attribution = updater record.attribution }


{-| Supported languages
-}
type Language
    = EN
    | NL


type alias ProfilingState =
    { profilingMode : InputMode
    , profilingText : String
    , result : Maybe AttributionResponse2
    }


{-| The pages that the application can be on
-}
type Route
    = Home
    | AttributionRoute
    | ProfilingRoute


{-| How the user inputs a document
-}
type InputMode
    = FileUpload
    | PasteText


{-| Request to the server

Example JSON:
{ "knownAuthorText": "lorem", "unknownAuthorText": "ipsum" }

-}
type alias AuthorRequest =
    { knownAuthorText : String, unknownAuthorText : String }



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
    { gender : String, age : Float }


{-| A shorthand for creating a tuple, saves typing parenthises
-}
(=>) : a -> b -> ( a, b )
(=>) =
    (,)


encodeToServer : ToServer -> Encode.Value
encodeToServer toServer =
    Encode.object
        [ "knownAuthorText" => Encode.string toServer.knownAuthorText
        , "unknownAuthorText" => Encode.string toServer.unknownAuthorText
        ]


decodeAttributionResponse : Decode.Decoder AttributionResponse
decodeAttributionResponse =
    Decode.succeed AttributionResponse
        |> required "sameAuthor" bool
        |> required "confidence" float
