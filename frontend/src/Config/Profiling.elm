module Config.Profiling exposing (..)

import Dict exposing (Dict)
import Data.Language exposing (Language(..))
import Data.Attribution.Genre exposing (Genre(..))


defaultLanguage : Language
defaultLanguage =
    EN


availableLanguages : List Language
availableLanguages =
    [ EN, NL, SP ]
