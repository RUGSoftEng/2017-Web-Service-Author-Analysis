module Data.Attribution.Input exposing (..)

import Json.Encode as Encode
import InputField
import Data.TextInput as TextInput exposing (TextInput)
import Data.Language as Language exposing (Language)
import Data.Attribution.Genre as Genre exposing (Genre)


type alias Input =
    { knownAuthor : InputField.Model
    , unknownAuthor : InputField.Model
    , language : Language
    , languages : List Language
    , featureCombo : FeatureCombo
    , featureCombos : List FeatureCombo
    , genre : Genre
    }


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


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


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
