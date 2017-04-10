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
    | AttributionInputField Author InputField.Msg
    | AttributionStatisticsMsg PlotSlideShow.Msg


type Author
    = KnownAuthor
    | UnknownAuthor


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


{-| Supported languages
-}
type Language
    = EN
    | NL


{-| The feature combo to use

The feature combo determines what characteristics of a text are
used and how strongly they are weighted.
-}
type FeatureCombo
    = Combo1
    | Combo4
