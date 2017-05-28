module Pages.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.Navbar as Navbar
import I18n exposing (Translation)
import Route
import Views.Page exposing (mainNav)


textCenter =
    Col.attrs [ class "text-center" ]


view : Translation -> Html ()
view _ =
    div [ class "home maincontainer" ]
        [ header [ class "header", id "home", attribute "style" "min-height: 76px;" ]
            [ mainNav (\_ -> ()) (Tuple.first <| Navbar.initialState (\_ -> ()))
            , div [ class " home-header-wrap" ]
                [ div [ class "header-content-wrap" ]
                    [ div [ class "container" ]
                        [ h1 [ class "intro-text" ]
                            [ text "Author Analysis" ]
                        ]
                    ]
                , div [ class "clear" ]
                    []
                ]
            ]
        , Grid.container [ style [ ( "width", "60%" ) ] ]
            [ Grid.row [ Row.topXs ]
                [ Grid.col [ textCenter, Col.attrs [ id "attribution-square" ] ]
                    [ span [] [ text "Attribution" ]
                    , text """ given one or more texts that we know are written by the same person, the system
                    will predict whether a new, unknown text is also written by the same person.
                    """
                    ]
                , Grid.col [ textCenter, Col.attrs [ id "profiling-square" ] ]
                    [ span [] [ text "Profiling" ]
                    , text """ given a text the system will predict the gender and age of the author."""
                    ]
                ]
            , Grid.row []
                [ Grid.col []
                    [ text """
Author analysis is relevant in literature studies, modern
and old, in law, when working with social media
contexts, politics, and any other field where
identifying who wrote something provides valuable
information. It also relates to the currently very hot
topic of alternative news.
"""
                    ]
                ]
            ]
        , footer [ id "footer" ]
            [ div [ class "container" ]
                [ div [ class "col-md-3 company-details" ]
                    [ div [ class "zerif-footer-address" ]
                        [ text "" ]
                    ]
                ]
            ]
        ]
