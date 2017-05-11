module Data.File exposing (..)

import Json.Decode as Decode exposing (Decoder, string, int, float)
import Json.Decode.Pipeline as Decode exposing (decode, required)
import String
import Dict exposing (Dict)


type alias File =
    { name : String
    , content : String
    }
