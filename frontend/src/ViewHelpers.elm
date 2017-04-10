module ViewHelpers exposing (..)

{-| Some reusable bits of view code.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Json.Decode as Decode
import Bootstrap.Grid as Grid
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Button as Button


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


{-| Language selection

this can't be in ViewHelpers because it creates circular dependencies (via Types.elm, which is needed for Language)
-}
languageSelector : String -> (language -> msg) -> List language -> language -> Html msg
languageSelector name toMsg languages current =
    let
        languageButton language =
            ButtonGroup.radioButton
                (language == current)
                [ Button.primary, Button.onClick (toMsg language) ]
                [ text (toString language) ]
    in
        ButtonGroup.radioButtonGroup [ ButtonGroup.vertical ] (List.map languageButton languages)


featureComboSelector : String -> (combo -> msg) -> (combo -> String) -> List combo -> combo -> Html msg
featureComboSelector name toMsg toLabel featureCombos current =
    let
        featureComboButton featureCombo =
            ButtonGroup.radioButton
                (featureCombo == current)
                [ Button.primary, Button.onClick (toMsg featureCombo) ]
                [ text (toLabel featureCombo) ]
    in
        ButtonGroup.radioButtonGroup [ ButtonGroup.vertical ] (List.map featureComboButton featureCombos)
