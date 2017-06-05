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
    case (language, genre) of
      (EN, Essay) ->
        {- When switching language to English with genre "Essay"
        * The genre "Essay" is not default language of English.
          This function will set genre of English to Essay.
        -}
        Essay

      _ ->
        {- Otherwise, this function will set genre to default genre.
        -}
        defaultGenre language
