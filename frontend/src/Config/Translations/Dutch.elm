module Config.Translations.Dutch exposing (..)

import Dict
import I18n exposing (Translations)
import Utils exposing ((=>))
import Data.Language exposing (Language(..))
import Data.Attribution.Genre exposing (Genre(..))


translations : Translations
translations =
    { general = general
    , home = home
    , attribution = attribution
    , profiling = profiling
    , attributionPrediction = attributionPrediction
    , profilingPrediction = profilingPrediction
    , attributionPlots = attributionPlots
    , profilingPlots = profilingPlots
    , input = input
    , genre = genre
    , language = language
    }


general =
    Dict.fromList
        [ "profiling" => "Profileren"
        , "attribution" => "Attributie"
        , "author-analysis" => "Author Analysis"
        ]


attribution =
    Dict.fromList
        [ "title" => "Attributie"
        , "explanation" => "Het attributiesysteem voorspelt hoe waarschijnlijk het is dat twee teksten door dezelfde auteur zijn geschreven."
        , "known-author-label" => "Teksten van de bekende auteur"
        , "known-author-description" => "Plaats hier teksten waarvan de auteur bekend is. Tekst kan geplakt worden, of een of meer bestanden geüpload. "
        , "unknown-author-label" => "Tekst van een onbekende auteur"
        , "unknown-author-description" => "Plaats hier een tekst waarvan de auteur onbekend is. Tekst kan geplakt worden, of een of meer bestanden geüpload. "
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
        , "loading-performing-analysis" => "Analyseren"
        , "loading-cancel" => "Cancel"
        ]


attributionPrediction =
    Dict.fromList
        [ "title" => "Resultaten"
        , "same-author-confidence" => "Vertrouwen zelfde auteur"
        , "document-analysis" => "Documentanalyse"
        ]


attributionPlots =
    let
        toPair { name, id, title, description } =
            [ (id ++ "-name") => name
            , (id ++ "-title") => title
            , (id ++ "-description") => description
            ]

        full =
            [ { name = "punctuation"
              , id = "punctuation"
              , title = "punctuation per character"
              , description = "The usage of punctuation is indicative of the author based on the differences in use of typographical signs (exclamation marks, question marks, semi-colons, colons, commas, full stops, hyphens and quotation marks)"
              }
            , { id = "line-endings"
              , name = "line endings"
              , title = "line endings per character"
              , description = "The usage of line endings is indicative of the author based on the preferred ways of closing lines (full stops, commas, question marks, exclamation marks, spaces, hyphens, and semi-colons)"
              }
            , { name = "ngram SIM"
              , id = "ngram-sim"
              , title = "ngram similarity"
              , description = "The ngram similarity with n ranging from 1 to 5 is measured by n-gram norm and SPI"
              }
            , { name = "ngram SPI"
              , id = "ngram-spi"
              , title = "ngram SPI"
              , description = "The ngram spi is a simple n-gram (n ranging from 1 to 5) overlap measure which based on the number of common n-grams in the most frequent n-grams for each document"
              }
            , { name = "similarities"
              , id = "similarities"
              , title = "similarities"
              , description = "A cosine similarity for the property vectors punctuation, line endings and line length, and simple subtraction for letter case and text block"
              }
            ]
    in
        List.concatMap toPair full
            |> Dict.fromList


profiling =
    Dict.fromList
        [ "title" => "Profileren"
        , "analyze" => "Analyseer!"
        , "profiling-explanation" => "Het profileersysteem voorspelt op basis van een tekst de leeftijd en het geslacht van de auteur"
        , "profiling-label" => "Profileer"
        , "profiling-description" => "Plaats hier een tekst. Tekst kan geplakt worden, of een of meer bestanden geüpload. "
        , "profiling-settings-language" => "Taal"
        , "profiling-settings-language-description" => "Selecteer de taal waarin de tekst geschreven is"
        , "loading-performing-analysis" => "Analyseren"
        , "loading-cancel" => "Cancel"
        ]


profilingPrediction =
    Dict.fromList
        [ "results" => "Resultaten"
        , "gender" => "Geslacht"
        , "plots" => "Plots"
        ]


profilingPlots =
    let
        full =
            [ { id = "age-distribution"
              , name = "age"
              , title = "Age Distribution"
              , description = "Probability distribution for age"
              }
            ]

        toPair { name, id, title, description } =
            [ (id ++ "-name") => name
            , (id ++ "-title") => title
            , (id ++ "-description") => description
            ]
    in
        List.concatMap toPair full
            |> Dict.fromList


home =
    Dict.fromList
        [ "attribution-description" => "Voorspelt aan de hand van teksten van een bekende auteur, hoe waarschijnlijk het is dat een onbekende tekst door dezelfde persoon geschreven is."
        , "profiling-description" => "Voorspelt de leeftijd en het geslacht van een auteur op basis van een tekst."
        , "rationale" => """
Author analysis is relevant in literature studies, modern
and old, in law, when working with social media
contexts, politics, and any other field where
identifying who wrote something provides valuable
information. It also relates to the currently very hot
topic of alternative news.
"""
        ]


input =
    Dict.fromList
        [ "paste-text" => "Plak Tekst"
        , "upload-file" => "Upload Bestand"
        , "choose-file" => "Selecteer een Bestand"
        ]


genre =
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


language =
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
