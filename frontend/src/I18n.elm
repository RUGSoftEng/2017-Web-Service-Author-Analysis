module I18n exposing (..)

import Dict exposing (Dict)


type alias Translations =
    { attribution : Translation, profiling : Translation }


type alias Translation =
    Dict String String


get : Translation -> String -> String
get dict key =
    dict
        |> Dict.get key
        |> Maybe.withDefault key


(=>) =
    (,)


english =
    { attribution =
        Dict.fromList
            [ "explanation" => "The Authorship Attribution System will, given one or more texts of which it is known that they are written by the same author, predict whether a new, unknown is also written by the same person."
            , "known-author-label" => "Known author texts"
            , "known-author-description" => "Place here the texts of which the author is known. The text can either be pasted directly, or one or more files can be uploaded."
            , "unknown-author-label" => "Unknown author text"
            , "unknown-author-description" => "Place here the text of which the author is unknown. The text can either be pasted directly, or one file can be uploaded."
            , "settings-language" => "Select the language in which all texts are written"
            , "settings-genre" => "Select the genre of the text"
            , "settings-feature-set" => "Select the feature combination"
            ]
    , profiling =
        Dict.fromList
            [ "profiling-explanation" => "The Author Profiling System will, given a text, try to predict its author's age and gender."
            , "profiling-settings-language" => "Select the language in which the text is written"
            ]
    }
