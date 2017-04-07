module ViewHelpers exposing (..)

{-| Some reusable bits of view code.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Json.Decode as Decode
import Bootstrap.Grid as Grid


{-| A big horizontal bar displaying a title and subtitle
-}
jumbotron : String -> String -> Html msg
jumbotron title subtitle =
    div [ class "jumbotron" ]
        [ Grid.container []
            [ h1 [ class "display-3" ] [ text title ]
            , p [] [ text subtitle ]
            ]
        ]
