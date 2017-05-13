module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Json.Encode as Encode


---

import Data.TextInput as TextInput


all : Test
all =
    describe "Data - tests on our data structures"
        [ describe "TextInput" <|
            let
                input =
                    Fuzz.bool
                        |> Fuzz.andThen
                            (\convert ->
                                if convert then
                                    Fuzz.map (TextInput.toUpload << TextInput.fromString) Fuzz.string
                                else
                                    Fuzz.map TextInput.fromString Fuzz.string
                            )
            in
                [ fuzz input "idempotence: toUpload = toUpload << toUpload" <|
                    \textinput ->
                        textinput
                            |> TextInput.toUpload
                            |> TextInput.toUpload
                            |> Expect.equal (TextInput.toUpload textinput)
                , test "encoder" <|
                    \() ->
                        TextInput.fromString "42"
                            |> TextInput.encoder
                            |> Encode.encode 0
                            |> Expect.equal """["42"]"""
                ]
        , describe "Fuzz test examples, using randomly generated input"
            [ fuzz (list int) "Lists always have positive length" <|
                \aList ->
                    List.length aList |> Expect.atLeast 0
            , fuzz (list int) "Sorting a list does not change its length" <|
                \aList ->
                    List.sort aList |> List.length |> Expect.equal (List.length aList)
            , fuzzWith { runs = 1000 } int "List.member will find an integer in a list containing it" <|
                \i ->
                    List.member i [ i ] |> Expect.true "If you see this, List.member returned False!"
            , fuzz2 string string "The length of a string equals the sum of its substrings' lengths" <|
                \s1 s2 ->
                    s1 ++ s2 |> String.length |> Expect.equal (String.length s1 + String.length s2)
            ]
        ]
