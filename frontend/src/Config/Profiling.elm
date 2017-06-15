module Config.Profiling exposing (..)

import Data.Language exposing (Language(..))


defaultLanguage : Language
defaultLanguage =
    EN


availableLanguages : List Language
availableLanguages =
    [ EN, SP ]
