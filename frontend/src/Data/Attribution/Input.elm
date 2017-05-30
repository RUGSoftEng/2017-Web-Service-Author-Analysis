module Data.Attribution.Input exposing (..)

import Char
import Json.Encode as Encode
import Result.Extra as Result
import Utils exposing ((=>))
import InputField
import Data.TextInput as TextInput exposing (TextInput)
import Data.Language as Language exposing (Language)
import Data.Attribution.Genre as Genre exposing (Genre)
import Bootstrap.Popover as Popover


type alias Input =
    { knownAuthor : InputField.Model
    , unknownAuthor : InputField.Model
    , language : Language
    , languages : List Language
    , featureCombo : FeatureCombo
    , featureCombos : List FeatureCombo
    , genre : Genre
    , popovers : { deep : Popover.State, shallow : Popover.State }
    }


type Validation
    = Warning (List String)
    | Error (List String)
    | Success


validate : String -> Validation
validate str =
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
        Err message
    else
        Ok ()


warnings : String -> Result (List String) ()
warnings str =
    let
        tooShort =
            { validator = \str -> String.length str > 140
            , message = "Your input is a little short, try adding some more for better predictions"
            }

        checks =
            [ tooShort ]
    in
        List.map (boolCheck str) checks
            |> combineErrors


errors str =
    let
        isNotEmpty =
            { validator = not << String.isEmpty
            , message = "The system needs text to analyze. Please give it some"
            }

        containsLowercase =
            { validator = String.any (Char.isLower)
            , message = "The system needs at least one lowercase character in your texts"
            }

        checks =
            [ isNotEmpty
            , containsLowercase
            ]
    in
        List.map (boolCheck str) checks
            |> combineErrors


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


type Author
    = KnownAuthor
    | UnknownAuthor


{-| The feature combo description
The feature combo determines what characteristics of a text are
used and how imporant they are to for making a prediction.
combo1: n-grams, visual
combo2: n-grams, visual, token
combo3: n-grams, visual, token, entropy (joint)
combo4: full set (excluding morpho(syntactic) features)
n-gram: a contiguous sequence of n items from a given sequence of text.
visual: a feature contains Punctuation, Line endings, and Letter case.
token: a joint feature measure the similarity in each training instance by averaging over the L2-normalised dot product
       of the raw term frequency vectors of a single known document and the unknown document.
entropy: authors have distinct entropy profiles due to the varying lexical and morphosyntactic
         patterns they use.
-}
type FeatureCombo
    = Combo1
    | Combo4


encoder : Input -> Encode.Value
encoder attribution =
    let
        featureComboToInt combo =
            case combo of
                Combo1 ->
                    1

                Combo4 ->
                    4
    in
        Encode.object
            [ "knownAuthorTexts" => TextInput.encoder attribution.knownAuthor.input
            , "unknownAuthorText" => TextInput.firstFileEncoder attribution.unknownAuthor.input
            , "language" => Language.encoder attribution.language
            , "genre" => Genre.encoder attribution.genre
            , "featureSet" => Encode.int (featureComboToInt attribution.featureCombo)
            ]
