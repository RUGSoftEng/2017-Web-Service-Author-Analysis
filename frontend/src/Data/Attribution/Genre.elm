module Data.Attribution.Genre exposing (..)

import Json.Encode as Encode


type Genre
    = Essay
    | Review
    | Article
    | Novel
    | Email


genreToString : Genre -> String
genreToString genre =
    case genre of
        Essay ->
            "essay"

        Review ->
            "review"

        Article ->
            "article"

        Novel ->
            "novel"

        Email ->
            "email"


encoder : Genre -> Encode.Value
encoder genre =
    Encode.string (genreToString genre)
