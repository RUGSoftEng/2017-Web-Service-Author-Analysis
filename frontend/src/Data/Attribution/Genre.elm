module Data.Attribution.Genre exposing (..)

import Json.Encode as Encode


type Genre
    = Essay
    | Review
    | Article
    | Novel
    | Email


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


encoder genre =
    Encode.string (genreToString genre)
