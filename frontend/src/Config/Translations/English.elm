module Config.Translations.English exposing (..)

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
        [ "profiling" => "Profiling"
        , "attribution" => "Attribution"
        , "author-analysis" => "Author Analysis"
        ]


attribution =
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
        , "loading-performing-analysis" => "Performing analysis"
        , "loading-cancel" => "Cancel"
        ]


attributionPrediction =
    Dict.fromList
        [ "title" => "Results"
        , "same-author-confidence" => "Same author confidence"
        , "document-analysis" => "Document Analysis"
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
        [ "title" => "Profiling"
        , "analyze" => "Analyze!"
        , "profiling-explanation" => "The Author Profiling System will, given a text, try to predict its author's age and gender."
        , "profiling-label" => "Profiling text"
        , "profiling-description" => "Place here the text of which the author is unknown. The text can either be pasted directly, or one file can be uploaded."
        , "profiling-settings-language" => "Language"
        , "profiling-settings-language-description" => "Select the language in which the text is written"
        , "loading-performing-analysis" => "Performing analysis"
        , "loading-cancel" => "Cancel"
        ]


profilingPrediction =
    Dict.fromList
        [ "title" => "Results"
        , "gender" => "Gender"
        , "plots" => "Plots"
        ]


profilingPlots =
    let
        full =
            [ { id = "age-distribution"
              , name = "age"
              , title = "age-distribution"
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
        [ "attribution-description" => "Given one or more texts that we know are written by the same person, the system will predict whether a new, unknown text is also written by the same person."
        , "profiling-description" => "Given a text the system will predict the gender and age of the author."
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
        [ "paste-text" => "Paste Text"
        , "upload-file" => "Upload File"
        , "choose-file" => "Choose File"
        ]


language =
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


genre =
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
