module ViewHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Json.Decode as Decode
import Bootstrap.Grid as Grid


jumbotron : String -> String -> Html msg
jumbotron title subtitle =
    div [ class "jumbotron" ]
        [ Grid.container []
            [ h1 [ class "display-3" ] [ text title ]
            , p [] [ text subtitle ]
            ]
        ]


{-| we have to do this html manually, until my fix to the elm-bootstrap package gets merged
(this should be early next week, I spoke with the package author).

Until then, just assume this function works

this doesn't go into a separate file because why would it? just adds overhead.
-}
radioButtons : String -> List ( Bool, msg, List (Html msg) ) -> Html msg
radioButtons groupName options =
    let
        viewRadioButton ( checked, onclick, children ) =
            label
                [ classList [ ( "btn", True ), ( "btn-primary", True ), ( "active", checked ) ]
                , onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed onclick)
                ]
                (input [ attribute "autocomplete" "off", attribute "checked" "", name groupName, type_ "radio" ] [] :: children)
    in
        div [ class "btn-group", attribute "data-toggle" "buttons" ] (List.map viewRadioButton options)
