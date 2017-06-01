module Config.Attribution exposing (..)

import Dict exposing (Dict)
import Data.Language exposing (Language(..))
import Data.Attribution.Genre exposing (Genre(..))


genres : Language -> List Genre
genres language =
    case language of
        EN ->
            [ Email, Essay, Novel ]

        NL ->
            [ Essay, Review ]

        GR ->
            [ Article ]

        SP ->
            [ Article ]


defaultLanguage : Language
defaultLanguage =
    EN


availableLanguages : List Language
availableLanguages =
    [ EN, NL, GR, SP ]


defaultGenre : Language -> Genre
defaultGenre language =
    case language of
        EN ->
            Email

        NL ->
            Essay

        GR ->
            Article

        SP ->
            Article

changeGenre : Language -> Genre -> Genre
changeGenre language genre =
    case language of
        EN ->
            case genre of
              Essay ->
                    Essay
              Review ->
                    Email
              Article ->
                    Email
              Email ->
                    Email
              Novel ->
                    Email


        NL ->
            Essay

        GR ->
            Article

        SP ->
            Article
