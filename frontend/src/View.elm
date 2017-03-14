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
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Json.Decode as Decode
import Types exposing (..)


{-| How the model is displayed
-}
view : Model -> Html Msg
view model =
    div []
        [ CDN.stylesheet
        , buttonStyle
        , navbar model
        , case model.route of
            Home ->
                homeView

            AuthorRecognition ->
                authorRecognitionView model.authorRecognition

            AuthorProfiling ->
                authorProfilingView model.authorProfiling
        , footer [ class "footer" ] [ footerbar model ]
        ]


navbar : Model -> Html Msg
navbar ({ navbarState } as model) =
    Navbar.config NavbarMsg
        |> Navbar.inverse
        |> Navbar.withAnimation
        |> Navbar.brand [ href "#", onClick (ChangeRoute Home) ] [ text "Author Analysis | " ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#", onClick (ChangeRoute AuthorRecognition) ] [ text "Attribution" ]
            , Navbar.itemLink [ href "#", onClick (ChangeRoute AuthorProfiling) ] [ text "Profiling" ]
            ]
        |> Navbar.view navbarState


footerbar : Model -> Html Msg
footerbar ({ navbarState } as model) =
    Navbar.config NavbarMsg
        |> Navbar.inverse
        |> Navbar.fixBottom
        |> Navbar.withAnimation
        |> Navbar.items
            -- TODO empty element. somehow needed for styling. need to look into this
            [ Navbar.itemLink [ href "#", onClick (ChangeRoute AuthorRecognition) ] [ text "" ]
            ]
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
        |> Navbar.view navbarState


homeView : Html msg
homeView =
    text "home"


profilingView : Html msg
profilingView =
    text "profiling"


authorRecognitionView : AuthorRecognitionState -> Html Msg
authorRecognitionView authorRecognition =
    let
        knownAuthorInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Known Author" ]
                , knownButtons
                , textarea
                    [ onInput SetKnownAuthorText
                    , defaultValue authorRecognition.knownAuthorText
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

        unknownAuthorInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Unknown Author" ]
                , unknownButtons
                , textarea
                    [ onInput SetUnknownAuthorText
                    , defaultValue authorRecognition.unknownAuthorText
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

        result =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "result: " ]
                , case authorRecognition.result of
                    Nothing ->
                        text ""

                    Just a ->
                        text (toString a)
                , languageSelector
                ]

        languageSelector =
            let
                language =
                    authorRecognition.language
            in
                radioButtons "authorRecognition.language"
                    [ ( language == EN, SetLanguage EN, [ text "EN" ] )
                    , ( language == NL, SetLanguage NL, [ text "NL" ] )
                    ]

        separator =
            Grid.col [ Col.xs2, Col.attrs [ class "text-center" ] ]
                [ Button.button [ Button.primary, Button.attrs [ onClick UploadAuthorRecognition ] ] [ text "compare with" ] ]

        knownButtons =
            let
                pasteText =
                    authorRecognition.knownAuthorMode == PasteText
            in
                radioButtons "known-author-inputmode"
                    [ ( pasteText, ToggleKnownAuthorInputMode, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleKnownAuthorInputMode, [ text "Upload File" ] )
                    ]

        unknownButtons =
            let
                pasteText =
                    authorRecognition.unknownAuthorMode == PasteText
            in
                radioButtons "unknown-author-inputmode"
                    [ ( pasteText, ToggleUnknownAuthorInputMode, [ text "Paste Text" ] )
                    , ( not pasteText, ToggleUnknownAuthorInputMode, [ text "Upload File" ] )
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


authorProfilingView : AuthorProfilingState -> Html Msg
authorProfilingView authorProfiling =
    let
        profilingInput =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "Text" ]
                , knownButtons
                , textarea
                    [ onInput SetProfilingText
                    , defaultValue authorProfiling.profilingText
                    , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                    ]
                    []
                ]

        result =
            Grid.col [ Col.md5, Col.attrs [ class "center-block text-center" ] ]
                [ h2 [] [ text "result: " ]
                , case authorProfiling.result of
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
                    authorProfiling.profilingMode == PasteText
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


{-| Make the buttons red.

This should be in a css file, but that requires serving through the node server
instead of elm-reactor. This has to happen at some point, but not now.
-}
buttonStyle : Html msg
buttonStyle =
    node "style"
        []
        [ text """
.btn-primary.active {
    background-color: #DC002D;
    border-color: #DC002D;
    }

.btn-primary {
    background-color: #A90023;
    border-color: #A90023;
    }

.btn-primary:hover {
    background-color: #DC002D;
    border-color: #DC002D;
    }
        """
        ]
