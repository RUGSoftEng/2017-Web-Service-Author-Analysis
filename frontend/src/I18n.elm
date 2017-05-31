module I18n exposing (..)

{-| Helpers for internationalization (I18n).

For our project, we just have english text, but most user-facing text is stored in this one file such that we can
easily translate it when needed.
-}

import Dict exposing (Dict)
import Data.Language exposing (Language(..))
import Data.Attribution.Genre exposing (Genre(..))


type alias Translations =
    { attribution : Translation
    , profiling : Translation
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


(=>) =
    (,)


dutch : Translations
dutch =
    { attribution =
        Dict.fromList
            [ "title" => "Attributie"
            , "explanation" => "Het attributiesysteem voorspelt hoe waarschijnlijk het is dat twee teksten door dezelfde auteur zijn geschreven."
            , "known-author-label" => "Teksten van de bekende auteur"
            , "known-author-description" => "Plaats hier teksten waarvan de auteur bekend is. Tekst kan geplakt worden, of een of meer bestanden geuploaded. "
            , "unknown-author-label" => "Tekst van een onbekende auteur"
            , "unknown-author-description" => "Plaats hier een tekst waarvan de auteur onbekend is. Tekst kan geplakt worden, of een of meer bestanden geuploaded. "
            , "compare" => "Vergelijk!"
            , "load-example-same-author" => "Laad voorbeeld - zelfde auteur"
            , "load-example-different-authors" => "Laad voorbeeld - verschillende auteurs"
            , "settings-language" => "Taal"
            , "settings-genre" => "Genre"
            , "settings-feature-set" => "Features"
            , "settings-language-description" => "Selecteer de taal waarin de teksten geschreven zijn"
            , "settings-genre-description" => "Selecteer het genre van de tekst. Het kiezen van het bestpassende genre kan iets beter voorspellingen geven"
            , "settings-feature-set-description" => "Selecteer welke combinatie van features word gebruikt"
            , "combo1" => "Meest belangrijk"
            , "combo4" => "Alle"
            , "combo1-description" => "Voorspel enkel met de meest belangrijke features"
            , "combo4-description" => "Gebruik alle features voor de voorspelling"
            ]
    , profiling =
        Dict.fromList
            [ "title" => "Profileren"
            , "analyze" => "Analyseer!"
            , "profiling-explanation" => "Het profileersysteem voorspelt op basis van een tekst de leeftijd en het geslacht van de auteur"
            , "profiling-label" => "Profileer"
            , "profiling-description" => "Plaats hier een tekst. Tekst kan geplakt worden, of een of meer bestanden geuploaded. "
            , "profiling-settings-language" => "Taal"
            , "profiling-settings-language-description" => "Selecteer de taal waarin de tekst geschreven is"
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
    , input =
        Dict.fromList
            [ "paste-text" => "Plak Tekst"
            , "upload-file" => "Upload Bestand"
            , "choose-file" => "Selecteer een Bestand"
            ]
    , genre =
        let
            genres =
                [ Email, Essay, Novel, Review, Article ]

            toPair genre =
                case genre of
                    Email ->
                        toString genre => "email"

                    Article ->
                        toString genre => "artikel"

                    Essay ->
                        toString genre => "essay"

                    Novel ->
                        toString genre => "verhaal"

                    Review ->
                        toString genre => "recensie"
        in
            List.map toPair genres
                |> Dict.fromList
    , language =
        let
            languages =
                [ EN, NL, SP, GR ]

            toPair language =
                case language of
                    EN ->
                        toString language => "Engels"

                    NL ->
                        toString language => "Nederlands"

                    SP ->
                        toString language => "Spaans"

                    GR ->
                        toString language => "Grieks"
        in
            -- this may look somewhat silly, but the above case statement makes sure that
            -- there is a translation for all languages.
            List.map toPair languages
                |> Dict.fromList
    }


english : Translations
english =
    { attribution =
        Dict.fromList
            [ "title" => "Attribution"
            , "explanation" => "The Authorship Attribution System will, given one or more texts of which it is known that they are written by the same author, predict whether a new, unknown is also written by the same person."
            , "known-author-label" => "Known author texts"
            , "known-author-description" => "Place here the texts of which the author is known. The text can either be pasted directly, or one or more files can be uploaded."
            , "unknown-author-label" => "Unknown author text"
            , "unknown-author-description" => "Place here the text of which the author is unknown. The text can either be pasted directly, or one file can be uploaded."
            , "compare" => "Compare!"
            , "load-example-same-author" => "Load Example - same author"
            , "load-example-different-authors" => "Load Example - different authors"
            , "settings-language" => "Language"
            , "settings-genre" => "Genre"
            , "settings-feature-set" => "Feature Set"
            , "settings-language-description" => "Select the language in which all texts are written"
            , "settings-genre-description" => "Select the genre of the text. Picking the closest genre can give slightly better predictions"
            , "settings-feature-set-description" => "Select the feature combination"
            , "combo1" => "Shallow"
            , "combo4" => "Deep"
            , "combo1-description" => "Only take the most important features into account"
            , "combo4-description" => "Take all features into account"
            ]
    , profiling =
        Dict.fromList
            [ "title" => "Profiling"
            , "analyze" => "Analyze!"
            , "profiling-explanation" => "The Author Profiling System will, given a text, try to predict its author's age and gender."
            , "profiling-label" => "Profiling text"
            , "profiling-description" => "Place here the text of which the author is unknown. The text can either be pasted directly, or one file can be uploaded."
            , "profiling-settings-language" => "Language"
            , "profiling-settings-language-description" => "Select the language in which the text is written"
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
    , input =
        Dict.fromList
            [ "paste-text" => "Paste Text"
            , "upload-file" => "Upload File"
            , "choose-file" => "Choose File"
            ]
    , language =
        let
            languages =
                [ EN, NL, SP, GR ]

            toPair language =
                case language of
                    EN ->
                        toString language => "English"

                    NL ->
                        toString language => "Dutch"

                    SP ->
                        toString language => "Spanish"

                    GR ->
                        toString language => "Greek"
        in
            -- this may look somewhat silly, but the above case statement makes sure that
            -- there is a translation for all languages.
            List.map toPair languages
                |> Dict.fromList
    , genre =
        let
            genres =
                [ Email, Article, Essay, Novel, Review ]

            toPair genre =
                case genre of
                    Email ->
                        toString genre => "email"

                    Article ->
                        toString genre => "article"

                    Essay ->
                        toString genre => "essay"

                    Novel ->
                        toString genre => "novel"

                    Review ->
                        toString genre => "review"
        in
            List.map toPair genres
                |> Dict.fromList
    }
