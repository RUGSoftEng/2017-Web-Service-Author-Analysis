module Data.Validation exposing (Validation(..), validate, boolCheck, combineErrors)

import Maybe.Extra as Maybe


type Validation
    = Warning String
    | Error String
    | Success
    | NotLoaded


type alias Validator =
    String -> Result (List String) ()


validate : { errors : List (String -> Maybe String), warnings : List (String -> Maybe String) } -> String -> Validation
validate { errors, warnings } str =
    -- first see if there are errors, if so report them
    -- then check for warnings. if there are any, report them
    -- otherwise, succeed
    let
        errorMessage =
            errors
                |> List.map (\f -> f str)
                |> List.foldl Maybe.or Nothing
                |> Maybe.map Error

        warningMessage =
            warnings
                |> List.map (\f -> f str)
                |> List.foldl Maybe.or Nothing
                |> Maybe.map Warning
    in
        Maybe.or errorMessage warningMessage
            |> Maybe.withDefault Success


orError : Result e a -> Result e a -> Result e a
orError x y =
    case x of
        Err e ->
            Err e

        Ok _ ->
            y


boolCheck : String -> { validator : String -> Bool, message : String } -> Result String ()
boolCheck str { validator, message } =
    if validator str then
        Ok ()
    else
        Err message


combineErrors : List (Result e a) -> Result (List e) a
combineErrors elems =
    case elems of
        [] ->
            Err []

        [ Ok v ] ->
            Ok v

        (Err y) :: xs ->
            case combineErrors xs of
                Ok _ ->
                    Err [ y ]

                Err errors ->
                    Err (y :: errors)

        (Ok _) :: xs ->
            combineErrors xs
