module Pages.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.Navbar as Navbar
import I18n exposing (Translation)
import Route
import Views.Page exposing (mainNav, viewFooter)


textCenter =
    Col.attrs [ class "text-center" ]


view : Translation -> Html ()
view translation =
    let
        t key =
            I18n.get translation key

        -- empty navbar state, we don't use it anyway
        navbarState =
            Tuple.first <| Navbar.initialState (\_ -> ())
    in
        div [ class "home maincontainer" ]
            [ header [ class "header", id "home", attribute "style" "min-height: 76px;" ] [ mainNav (\_ -> ()) (Tuple.first <| Navbar.initialState (\_ -> ())) ]
            , div [ class "home-header-wrap" ]
                [ div [ class "header-content-wrap" ]
                    [ div [ class "container" ]
                        [ h1 [ class "intro-text" ]
                            [ text "Author Analysis" ]
                        ]
                    ]
                , div [ class "clear" ]
                    []
                ]
            , Grid.container [ style [ ( "width", "60%" ) ] ]
                [ Grid.row [ Row.topXs ]
                    [ Grid.col [ textCenter, Col.attrs [ id "attribution-square" ] ]
                        [ a [ class "link-area", href "#/attribution" ]
                            [ div [ class "icon" ] []
                            , span [ class "title" ] [ text "Attribution" ]
                            , span [ class "description" ] [ text (t "attribution") ]
                            ]
                        ]
                    , Grid.col [ textCenter, Col.attrs [ id "profiling-square" ] ]
                        [ a [ class "link-area", href "#/profiling" ]
                            [ div [ class "icon" ] []
                            , span [ class "title" ] [ text "Profiling" ]
                            , span [ class "description" ] [ text (t "profiling") ]
                            ]
                        ]
                    ]
                , Grid.row [ Row.topXs, Row.attrs [ id "button-row" ] ]
                    [ Grid.col []
                        [ a [ class "go", attribute "role" "button", href "#/attribution" ] [ text "Go" ]
                        ]
                    , Grid.col []
                        [ a [ class "go", attribute "role" "button", href "#/profiling" ] [ text "Go" ]
                        ]
                    ]
                , Grid.row [] [ Grid.col [] [ text (t "rationale") ] ]
                ]
            , viewFooter navbarState
                |> Html.map (\_ -> ())
            ]
