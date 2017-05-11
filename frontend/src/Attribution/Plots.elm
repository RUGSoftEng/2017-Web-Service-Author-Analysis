module Attribution.Plots exposing (Statistics, FileStatistics, decodeStatistics, decodeFileStatistics, plots)

{-| Describes how we want to draw our plots (and which ones to draw)

Most of the heavy lifting is actually done by PlotSlideShow, which
will keep track of which plot has focus and how the title and description
are laid out around the plot.
-}

import Html exposing (text)
import Json.Decode as Decode exposing (Decoder, string, int, float)
import Json.Decode.Pipeline as Decode exposing (decode, required)
import Plot exposing (..)
import Dict exposing (Dict)
import PlotSlideShow exposing (Plot)
import Regex exposing (Regex, regex)


type alias Statistics =
    { known : FileStatistics
    , unknown : FileStatistics
    , ngramsSim : Dict Int Float
    , ngramsSpi : Dict Int Int
    , similarity : Dict String Float
    }


type alias FileStatistics =
    { characters : Float
    , lines : Float
    , blocks : Float
    , uppers : Float
    , lowers : Float
    , punctuation : Dict Char Float
    , lineEndings : Dict Char Float
    , sentences : Float
    , words : Float
    }


plots : Dict String (Plot Statistics msg)
plots =
    let
        data =
            [ { label = "punctuation"
              , title = "punctuation per character"
              , render = plotPunctuation
              , description = text "The usage of punctuation is indicative of the author based on the differences in use of typographical signs (exclamation marks, question marks, semi-colons, colons, commas, full stops, hyphens and quotation marks)"
              }
            , { label = "line endings"
              , title = "line endings per character"
              , render = plotLineEndings
              , description = text "The usage of line endings is indicative of the author based on the preferred ways of closing lines (full stops, commas, question marks, exclamation marks, spaces, hyphens, and semi-colons)"
              }
            , { label = "ngram SIM"
              , title = "anagram similarity"
              , render = plotNgramsSim
              , description = text "ngram similarity with n ranging from 1 to 5 measures by n-gram norm(According to [9], an author profile is defined as the set of the k most frequent n-grams with their normalised frequencies, as collected from training data. In order to deal with sparseness when n > 2, the (dis)similarity measure that they use, and that we adopt, takes into account the difference between the relative frequency of a given n-gram averaged over all known-unknown document pairs of one problem instance. We call this feature group n-gram norm ?) and SPI"
              }
            , { label = "ngram SPI"
              , title = "anagram SPI"
              , render = plotNgramsSpi
              , description = text "ngram spi is a simple n-gram with n ranging from 1 to 5 (a contiguous sequence of n items from a given sequence of text) overlap measure which based on the number of common n-grams in the most frequent n-grams for each document"
              }
            , { label = "similarities"
              , title = "similarities"
              , render = plotSimilarities
              , description = text "A cosine similarity(a measure of similarity between two non-zero vectors of an inner product space that measures the cosine of the angle between them) for the property vectors punctuation, line endings and line length, and simple subtraction for letter case and text block"
              }
            ]
    in
        List.map (\datum -> ( datum.label, PlotSlideShow.plot datum )) data
            |> Dict.fromList


{-| Construct a plot for punctuation

This module uses the excellent elm-plot package http://package.elm-lang.org/packages/terezka/elm-plot/latest

First we must turn the two punctuation dictionaries into something that elm-plot understands.
This is what construct does. Construct also scales the values, so all bar size's are withing one order of magnitude of one another.

List.map2 "zips together" two lists, for example

    List.map2 (+) [ 1,2 ] [ 13, 14 ] == [11, 16 ]

Finally, uncurry

    uncurry : (a -> b -> c) -> ((a, b) -> c)
    uncurry f (x, y) = f x y

    (uncurry (++)) ("foo", "bar") == "foobar"

allows us to use a normal function that takes two arguments, and apply it to a tuple containing two values.

Plot.viewBars takes care of all the rest.
-}
plotPunctuation : Statistics -> Html.Html msg
plotPunctuation { known, unknown } =
    let
        construct : ( Char, Float ) -> ( Char, Float ) -> ( String, List Float )
        construct ( label, v1 ) ( _, v2 ) =
            ( String.fromChar label, [ v1 / known.characters, v2 / known.characters ] )
    in
        List.map2 construct (Dict.toList known.punctuation) (Dict.toList unknown.punctuation)
            |> viewBars (groups (List.map (uncurry group)))


plotLineEndings : Statistics -> Html.Html msg
plotLineEndings { known, unknown } =
    let
        construct ( label, v1 ) ( _, v2 ) =
            ( String.fromChar label, [ v1 / known.lines, v2 / unknown.lines ] )
    in
        List.map2 construct (Dict.toList known.lineEndings) (Dict.toList unknown.lineEndings)
            |> viewBars (groups (List.map (uncurry group)))


plotAverages : Statistics -> Html.Html msg
plotAverages { known, unknown } =
    let
        data =
            [ ( "sentence length", [ known.sentences / known.lines, unknown.sentences / unknown.lines ] )
            , ( "words per line", [ known.words / known.lines, unknown.words, unknown.lines ] )
              -- , ( "lines per paragraph", [ known.lines / known.blocks, unknown.lines / unknown.blocks ] )
              -- , ( "uppercase per lowercase", [ known.uppers / known.lowers, unknown.uppers / unknown.lowers ] )
            ]
    in
        viewBars (groups (List.map (\( label, value ) -> group label value))) data


plotNgramsSim : Statistics -> Html.Html msg
plotNgramsSim { ngramsSim } =
    let
        construct ( key, value ) =
            ( toString key, [ value ] )
    in
        ngramsSim
            |> Dict.toList
            |> List.map construct
            |> viewBars (groups (List.map (uncurry group)))


plotNgramsSpi : Statistics -> Html.Html msg
plotNgramsSpi { ngramsSpi } =
    let
        construct ( key, value ) =
            ( toString key, [ toFloat value ] )
    in
        ngramsSpi
            |> Dict.toList
            |> List.map construct
            |> viewBars (groups (List.map (uncurry group)))


plotSimilarities : Statistics -> Html.Html msg
plotSimilarities { similarity } =
    let
        rename : String -> String
        rename str =
            str
                |> Regex.replace Regex.All (Regex.regex "_") (\_ -> " ")

        construct ( key, value ) =
            ( rename key, [ value ] )
    in
        similarity
            |> Dict.toList
            |> List.map construct
            |> viewBars (groups (List.map (uncurry group)))


decodeStatistics =
    Decode.succeed Statistics
        |> required "known" decodeFileStatistics
        |> required "unknown" decodeFileStatistics
        |> required "ngrams-sim" (dictBoth (Decode.decodeString int) float)
        |> required "ngrams-spi" (dictBoth (Decode.decodeString int) int)
        |> required "similarities" (Decode.dict float)


decodeFileStatistics =
    let
        stringToChar str =
            case String.uncons str of
                Just ( c, rest ) ->
                    if rest == "" then
                        Ok c
                    else
                        Err <| "trying to decode a single Char, but got `" ++ str ++ "`"

                Nothing ->
                    Err <| "decoding a char failed: no input"
    in
        decode FileStatistics
            |> required "characters" float
            |> required "lines" float
            |> required "blocks" float
            |> required "uppers" float
            |> required "lowers" float
            |> required "lineEndings" (dictBoth stringToChar float)
            |> required "punctuation" (dictBoth stringToChar float)
            |> required "sentences" float
            |> required "words" float


{-| Convert an object into a dictionary with decoded keys AND values.
the builtin dict decoder only allows you to decode values, defaulting keys to String
-}
dictBoth : (String -> Result String comparable) -> Decoder value -> Decoder (Dict comparable value)
dictBoth keyDecoder valueDecoder =
    let
        decodeKeys kvpairs =
            List.foldr decodeKey (Decode.succeed Dict.empty) kvpairs

        decodeKey ( key, value ) accum =
            case keyDecoder key of
                Err e ->
                    Decode.fail <| "decoding a key failed: " ++ e

                Ok newKey ->
                    Decode.map (Dict.insert newKey value) accum
    in
        Decode.keyValuePairs valueDecoder
            |> Decode.andThen decodeKeys


char =
    Decode.string
        |> Decode.andThen
            (\str ->
                case String.uncons str of
                    Just ( c, rest ) ->
                        if rest == "" then
                            Decode.succeed c
                        else
                            Decode.fail <| "trying to decode a single Char, but got `" ++ str ++ "`"

                    Nothing ->
                        Decode.fail <| "decoding a char failed: no input"
            )
