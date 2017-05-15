module Data.Helpers exposing (dictBoth, char)

import Json.Decode as Decode exposing (Decoder, string, int, float)
import Json.Decode.Pipeline as Decode exposing (decode, required)
import Dict exposing (Dict)


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


char : Decoder Char
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
