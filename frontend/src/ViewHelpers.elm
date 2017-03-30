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


{-| A group of mutually exclusive options
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


{-| A group of mutually exclusive options, displayed vertically
-}
radioButtonsVertical : String -> List ( Bool, msg, List (Html msg) ) -> Html msg
radioButtonsVertical groupName options =
    let
        viewRadioButton ( checked, onclick, children ) =
            label
                [ classList [ ( "btn", True ), ( "btn-primary", True ), ( "active", checked ) ]
                , onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed onclick)
                ]
                (input [ attribute "autocomplete" "off", attribute "checked" "", name groupName, type_ "radio" ] [] :: children)
    in
        div [ class "btn-group-vertical", attribute "data-toggle" "buttons" ] (List.map viewRadioButton options)
