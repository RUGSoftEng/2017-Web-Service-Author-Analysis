module Data.Language exposing (..)

{-| Supported languages
-}

import Json.Encode as Encode


type Language
    = EN
    | NL
    | SP
    | GR


encoder language =
    Encode.string (toString language)
