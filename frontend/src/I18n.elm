module I18n exposing (..)

{-| Helpers for internationalization (I18n).

For our project, we just have english text, but most user-facing text is stored in this one file such that we can
easily translate it when needed.
-}

import Dict exposing (Dict)


type alias Translations =
    { general : Translation
    , attribution : Translation
    , attributionPrediction : Translation
    , attributionPlots : Translation
    , profiling : Translation
    , profilingPrediction : Translation
    , profilingPlots : Translation
    , home : Translation
    , input : Translation
    , language : Translation
    , genre : Translation
    }


type alias Translation =
    Dict String String


type alias Translator =
    String -> String


get : Translation -> String -> String
get dict key =
    dict
        |> Dict.get key
        |> Maybe.withDefault key
