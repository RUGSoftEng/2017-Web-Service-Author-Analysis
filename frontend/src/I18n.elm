module I18n exposing (..)

{-| Helpers for internationalization (I18n).

For our project, we just have english text, but most user-facing text is stored in this one file such that we can
easily translate it when needed.
-}

import Dict exposing (Dict)
import Utils exposing ((=>))


type alias Translations =
    { attribution : Translation, profiling : Translation, home : Translation }


type alias Translation =
    Dict String String


get : Translation -> String -> String
get dict key =
    dict
        |> Dict.get key
        |> Maybe.withDefault key


english : Translations
english =
    { attribution =
        Dict.fromList
            [ "explanation" => "The Authorship Attribution System will, given one or more texts of which it is known that they are written by the same author, predict whether a new, unknown is also written by the same person."
            , "known-author-label" => "Known author texts"
            , "known-author-description" => "Place here the texts of which the author is known. The text can either be pasted directly, or one or more files can be uploaded."
            , "unknown-author-label" => "Unknown author text"
            , "unknown-author-description" => "Place here the text of which the author is unknown. The text can either be pasted directly, or one file can be uploaded."
            , "settings-language" => "Select the language in which all texts are written"
            , "settings-genre" => "Select the genre of the text. Picking the closest genre can give slightly better predictions"
            , "settings-feature-set" => "Select the feature combination"
            , "combo1" => "Shallow"
            , "combo4" => "Deep"
            , "combo1-description" => "Only take the most important features into account"
            , "combo4-description" => "Take all features into account"
            ]
    , profiling =
        Dict.fromList
            [ "profiling-explanation" => "The Author Profiling System will, given a text, try to predict its author's age and gender."
            , "profiling-label" => "Profiling text"
            , "profiling-description" => "Place here the text of which the author is unknown. The text can either be pasted directly, or one file can be uploaded."
            , "profiling-settings-language" => "Select the language in which the text is written"
            ]
    , home =
        Dict.fromList
            [ "attribution" => "Given one or more texts that we know are written by the same person, the system will predict whether a new, unknown text is also written by the same person."
            , "profiling" => "Given a text the system will predict the gender and age of the author."
            , "rationale" => """
Author analysis is relevant in literature studies, modern
and old, in law, when working with social media
contexts, politics, and any other field where
identifying who wrote something provides valuable
information. It also relates to the currently very hot
topic of alternative news.
"""
            ]
    }
