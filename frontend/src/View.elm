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
        [ navbar model
        , case model.route of
            Home ->
                homeView

            AttributionRoute ->
                Attribution.view model.attribution
                    |> Html.map AttributionMsg

            ProfilingRoute ->
                profilingView model.profiling
                    |> Html.map ProfilingMsg
        , footer [ class "footer" ] [ footerbar model ]
        ]


{-| The navigation bar at the top
-}
navbar : Model -> Html Msg
navbar ({ navbarState } as model) =
    let
        onClickStopEvent : Msg -> Attribute Msg
        onClickStopEvent msg =
            onWithOptions "click"
                { defaultOptions | stopPropagation = True, preventDefault = True }
                (Decode.succeed msg)
    in
        Navbar.config (NavbarMsg HeaderBar)
            |> Navbar.inverse
            |> Navbar.withAnimation
            -- The brand needs the href attribute to be specified.
            -- the href is the url (address) that the browser will navigate to when an item is clicked.
            -- Instead of letting the browser reload, we intercept and stop the signal and do our own routing
            |>
                Navbar.brand [ href "/", onClickStopEvent (ChangeRoute Home) ] [ text "Author Analysis | " ]
            |> Navbar.items
                [ Navbar.itemLink [ href "/attribution", onClickStopEvent (ChangeRoute AttributionRoute) ] [ text "Attribution" ]
                , Navbar.itemLink [ href "/profiling", onClickStopEvent (ChangeRoute ProfilingRoute) ] [ text "Profiling" ]
                ]
            |> Navbar.view navbarState


{-| The bar at the bottom, this is a modified navigation bar
-}
footerbar : Model -> Html Msg
footerbar ({ footerbarState } as model) =
    Navbar.config (NavbarMsg FooterBar)
        |> Navbar.inverse
        |> Navbar.fixBottom
        |> Navbar.customItems
            [ Navbar.customItem <|
                div
                    [ href "#"
                    , class "pull-right"
                    ]
                    [ img
                        [ src "https://nestor.rug.nl/branding/themes/student-portal-2016/rugimg/rug_logo_en.png"
                        , class "d-inline-block align-top"
                        , style [ "height" => "30px" ]
                        ]
                        []
                    ]
            ]
        |> Navbar.view footerbarState


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
