module Route exposing (Route(..), href, modifyUrl, fromLocation)

import UrlParser as Url exposing (parseHash, s, (</>), string, oneOf, Parser)
import Navigation exposing (Location)
import Html exposing (Attribute)
import Html.Attributes as Attr


type Route
    = Home
    | Attribution
    | Profiling
    | ProfilingPrediction
    | AttributionPrediction
    | AboutPage


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map Attribution (s "attribution")
        , Url.map AttributionPrediction (s "attribution" </> s "prediction")
        , Url.map Profiling (s "profiling")
        , Url.map ProfilingPrediction (s "profiling" </> s "prediction")
        , Url.map AboutPage (s "about")
        ]



--- INTERNAL ---


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Attribution ->
                    [ "attribution" ]

                Profiling ->
                    [ "profiling" ]

                AttributionPrediction ->
                    [ "attribution", "prediction" ]

                ProfilingPrediction ->
                    [ "profiling", "prediction" ]

                AboutPage ->
                    [ "about" ]
    in
        "#/" ++ String.join "/" pieces


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location
