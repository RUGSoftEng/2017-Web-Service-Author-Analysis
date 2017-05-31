module Data.Validation exposing (Validation(..), validate, boolCheck, combineErrors)

import Result.Extra as Result


type Validation
    = Warning (List String)
    | Error (List String)
    | Success
    | NotLoaded


type alias Validator =
    String -> Result (List String) ()


validate : { errors : Validator, warnings : Validator } -> String -> Validation
validate { errors, warnings } str =
    -- first see if there are errors, if so report them
    -- then check for warnings. if there are any, report them
    -- otherwise, succeed
    errors str
        |> Result.mapError Error
        |> Result.andThen
            (\_ ->
                warnings str
                    |> Result.mapError Warning
                    |> Result.map (\_ -> Success)
            )
        |> Result.merge


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
