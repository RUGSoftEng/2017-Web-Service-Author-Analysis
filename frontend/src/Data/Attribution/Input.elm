module Data.Attribution.Input exposing (..)

import Json.Encode as Encode
import InputField
import Data.Language as Language exposing (Language)


type alias Input =
    { knownAuthor : InputField.Model
    , unknownAuthor : InputField.Model
    , language : Language
    , languages : List Language
    , featureCombo : FeatureCombo
    , featureCombos : List FeatureCombo
    }


type Author
    = KnownAuthor
    | UnknownAuthor


{-| The feature combo to use

The feature combo determines what characteristics of a text are
used and how imporant they are to for making a prediction.
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
            [ "knownAuthorTexts" => InputField.encodeModel attribution.knownAuthor
            , "unknownAuthorText" => InputField.encodeFirstFile attribution.unknownAuthor
            , "language" => Language.encoder attribution.language
            , "genre" => Encode.int 0
            , "featureSet" => Encode.int (featureComboToInt attribution.featureCombo)
            ]
