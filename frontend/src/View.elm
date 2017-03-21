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
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Json.Decode as Decode
import Types exposing (..)


{-| How the model is displayed


note on styles/css:

currently these are inserted as <style> tags into the html (specifically within <body>). This is not ideal
for many reasons, but has been convenient so far because we don't need to do any server configuration

This will/should change in the second iteration, where the nodejs backend will actually serve the elm code
and the resources it needs.

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
    div []
        [ navbar model
        , case model.route of
            Home ->
                homeView

            AttributionRoute ->
                attributionView model.attribution
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
        onClickStopEvent msg =
            onWithOptions "click"
                { defaultOptions | stopPropagation = True, preventDefault = True }
                (Decode.succeed msg)
    in
        Navbar.config NavbarMsg
            |> Navbar.inverse
            |> Navbar.withAnimation
            -- the brand needs the href attribute to be specified (no idea why).
            -- there is no meaningful value for it, so we define `href='#'`.
            -- but, when the href attribute is '#', firefox will reload the page when the element is clicked (chrome will not).
            -- To prevent the reload (in firefox), we stop the event here.
            |>
                Navbar.brand [ href "#", onClickStopEvent (ChangeRoute Home) ] [ text "Author Analysis | " ]
            |> Navbar.items
                [ Navbar.itemLink [ onClick (ChangeRoute AttributionRoute) ] [ text "Attribution" ]
                , Navbar.itemLink [ onClick (ChangeRoute ProfilingRoute) ] [ text "Profiling" ]
                ]
            |> Navbar.view navbarState


{-| The bar at the bottom, this is a modified navigation bar

TODO separate this bar from the top one
-}
footerbar : Model -> Html Msg
footerbar ({ navbarState } as model) =
    Navbar.config NavbarMsg
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
        -- this is a little hacky, we reuse the state for
        -- the top and bottom bar.
        |>
            Navbar.view navbarState


homeView : Html msg
homeView =
    text "home"


attributionView : AttributionState -> Html AttributionMessage
attributionView attribution =
    let
        knownAuthorInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Known Author" ]
                , knownButtons
                , textarea
                    [ onInput (SetText KnownAuthor)
                    , defaultValue attribution.knownAuthorText
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

        unknownAuthorInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Unknown Author" ]
                , unknownButtons
                , textarea
                    [ onInput (SetText UnknownAuthor)
                    , defaultValue attribution.unknownAuthorText
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

        result =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "result: " ]
                , case attribution.result of
                    Nothing ->
                        text "No result yet"

                    Just a ->
                        text (toString a)
                ]

        languageSelector =
            let
                language =
                    attribution.language
            in
                div []
                    [ text "Language:"
                    , radioButtons "attribution-language"
                        [ ( language == EN, SetLanguage EN, [ text "EN" ] )
                        , ( language == NL, SetLanguage NL, [ text "NL" ] )
                        ]
                    ]

        separator =
            Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ]
                [ Button.button [ Button.primary, Button.attrs [ onClick PerformAttribution ] ] [ text "compare with" ]
                , languageSelector
                ]

        knownButtons =
            let
                pasteText =
                    attribution.knownAuthorMode == PasteText
            in
                radioButtons "known-author-inputmode"
                    [ ( pasteText, ToggleInputMode KnownAuthor, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleInputMode KnownAuthor, [ text "Upload File" ] )
                    ]

        unknownButtons =
            let
                pasteText =
                    attribution.unknownAuthorMode == PasteText
            in
                radioButtons "unknown-author-inputmode"
                    [ ( pasteText, ToggleInputMode UnknownAuthor, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleInputMode UnknownAuthor, [ text "Upload File" ] )
                    ]
    in
        div []
            [ div [ class "jumbotron" ]
                [ Grid.container []
                    [ h1 [ class "display-3" ] [ text "Author Recognition" ]
                    , p [] [ text "Predict whether two texts are written by the same author" ]
                    ]
                ]
            , Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ result ]
                , Grid.row [ Row.topXs ]
                    [ knownAuthorInput
                    , separator
                    , unknownAuthorInput
                    ]
                ]
            ]


profilingView : ProfilingState -> Html ProfilingMessage
profilingView profiling =
    let
        profilingInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Text" ]
                , knownButtons
                , textarea
                    [ onInput SetProfilingText
                    , defaultValue profiling.text
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

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

        knownButtons =
            let
                pasteText =
                    profiling.mode == PasteText
            in
                radioButtons "profiling-inputmode"
                    [ ( pasteText, ToggleProfilingInputMode, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleProfilingInputMode, [ text "Upload File" ] )
                    ]
    in
        div []
            [ div [ class "jumbotron" ]
                [ Grid.container []
                    [ h1 [ class "display-3" ] [ text "Author Profiling" ]
                    , p [] [ text "Predict the age and the gender of the Author of the text" ]
                    ]
                ]
            , Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ profilingInput
                    , separator
                    , result
                    ]
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
