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
import PlotSlideShow
import DisplayMode exposing (DisplayMode)
import Attribution.Plots


{-| Our model of the world
-}
type alias Model =
    { route : Route
    , navbarState : Navbar.State
    , footerbarState : Navbar.State
    , profiling : ProfilingState
    , attribution : DisplayMode ()
    }


{-| All the actions our application can perform
-}
type Msg
    = NoOp
    | NavbarMsg () Navbar.State
    | ChangeRoute Route
    | AttributionMsg ()
    | ProfilingMsg ProfilingMessage
    | UrlChange Navigation.Location
    | AddFile ( String, File )


type ProfilingMessage
    = ProfilingInputField InputField.Msg
    | UploadAuthorProfiling


{-| type alias with the same name.
this is the (only) way to re-export a type
-}
type alias File =
    InputField.File



-- nested structures


type alias ProfilingState =
    { input : InputField.Model
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
