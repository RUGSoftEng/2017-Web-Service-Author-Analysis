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

{-| Update Genre when switch languages
* When switching languages, some genres are not available. For example, genre "email" only existed in English.
- This function will keep set genre of new language same to previous language.
- If genre is not existed in new language, this function will set it to default genre.
-}
changeGenre : Language -> Genre -> Genre
changeGenre language genre =
    case language of
        EN ->
            case genre of
              Essay -> Essay
              _ -> defaultGenre language

        _ -> defaultGenre language
