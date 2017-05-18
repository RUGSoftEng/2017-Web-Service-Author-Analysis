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
        , describe "Genre" [{- no sensible tests to make -}]
        ]
