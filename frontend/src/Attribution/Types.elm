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
    { knownAuthor : InputField.State
    , unknownAuthor : InputField.State
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


{-| The feature combo to use

The feature combo determines what characteristics of a text are
used and how imporant they are to for making a prediction.
-}
type FeatureCombo
    = Combo1
    | Combo4
