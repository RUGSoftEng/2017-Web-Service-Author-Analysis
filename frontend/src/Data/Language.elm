module Data.Language exposing (..)

{-| Supported languages
-}

import Json.Encode as Encode


type Language
    = EN
    | NL
    | SP
    | GR


fullName : Language -> String
fullName language =
    case language of
        EN ->
            "English"

        NL ->
            "Dutch"

        SP ->
            "Spanish"

        GR ->
            "Greek"


encoder : Language -> Encode.Value
encoder language =
    Encode.string (toString language)
