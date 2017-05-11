module View exposing (view)

{-| View.elm

Displays the model as html

This file heavily uses the Bootstrap css library and its wrapper elm-bootstrap.

http://getbootstrap.com/
http://elm-bootstrap.info/

package links

http://package.elm-lang.org/packages/elm-lang/html/latest
http://package.elm-lang.org/packages/rundis/elm-bootstrap/latest

-}

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Progress as Progress
import Json.Decode as Decode
import Dict exposing (Dict)
import Types exposing (..)
import Octicons exposing (searchIcon, searchOptions, xIcon, xOptions)
import ViewHelpers
import InputField
import DisplayMode exposing (DisplayMode(..))
import Attribution.View as Attribution


{-| How the model is displayed

html in elm:

html is represented by normal elm functions that take two arguments: a list of attributes and a list of children
Because the html in elm is just functions and values, normal language features can be used to create the markup
(if-then-else, case-of, variables, arithmetic) without the need for a special templating language

The type `Html Msg` means that the html can produce messages of type Msg, for instance when a button is clicked.

We also use `Html msg` (note the lowercase m in msg) in some places. The lower case name implies
that a piece of html is polymorphic in msg. This means that the piece of html produces no messages (so no buttons, no input fields) and
can be part of any piece of html, no matter its message type.
-}
view : Model -> Html Msg
view model =
    div [ id "maincontainer" ]
        [ header [] [ navbar model ]
        , case model.route of
            Home ->
                homeView

            AttributionRoute ->
                Html.map AttributionMsg <|
                    case model.attribution of
                        Editor attribution ->
                            Attribution.editor attribution

                        Results attribution ->
                            Attribution.results attribution

                        Loading _ ->
                            text ""

            ProfilingRoute ->
                profilingView model.profiling
                    |> Html.map ProfilingMsg
        , footer [ class "footer" ] [ footerbar model ]
        ]


homeView : Html msg
homeView =
    div []
        [ text "home"
        ]


profilingView : ProfilingState -> Html ProfilingMessage
profilingView profiling =
    let
        profilingInput =
            let
                config : InputField.ViewConfig
                config =
                    { label = "Text"
                    , radioButtonName = "profiling-mode-buttons"
                    , fileInputId = "profiling-file-input"
                    , info = ""
                    , multiple = False
                    }
            in
                Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                    (InputField.view config profiling.input
                        |> List.map (Html.map ProfilingInputField)
                    )

        result =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "result: " ]
                , case profiling.result of
                    Nothing ->
                        text ""

                    Just a ->
                        text (toString a)
                ]

        separator =
            Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ]
                [ Button.button [ Button.primary, Button.attrs [ onClick UploadAuthorProfiling ] ] [ text "profiling" ] ]
    in
        div []
            [ ViewHelpers.jumbotron "Author Profiling" "Predict the age and the gender of the Author of the text"
            , Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ profilingInput
                    , separator
                    , result
                    ]
                ]
            ]
