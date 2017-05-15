module Attribution.Types exposing (Model, Msg(..), Author(..), FeatureCombo(..), Language(..))

import Http
import RemoteData exposing (WebData)


--

import InputField
import PlotSlideShow
import Attribution.Plots as Plots


type Msg
    = SetLanguage Language
    | SetFeatureCombo FeatureCombo
    | PerformAttribution
    | ServerResponse (WebData ( Float, Plots.Statistics ))
    | InputFieldMsg Author InputField.Msg
    | PlotSlideShowMsg PlotSlideShow.Msg


type alias Model =
    { knownAuthor : InputField.Model
    , unknownAuthor : InputField.Model
    , result : WebData ( Float, Plots.Statistics )
    , language : Language
    , languages : List Language
    , featureCombo : FeatureCombo
    , featureCombos : List FeatureCombo
    , plotState : PlotSlideShow.State
    }


type Author
    = KnownAuthor
    | UnknownAuthor


{-| Supported languages
-}
type Language
    = EN
    | NL


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
