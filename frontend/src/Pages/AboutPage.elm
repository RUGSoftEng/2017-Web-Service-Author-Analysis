module Pages.AboutPage exposing (..)

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
            [ header [ class "header", id "aboutPage", attribute "style" "min-height: 76px;" ] [ mainNav t (\_ -> ()) (Tuple.first <| Navbar.initialState (\_ -> ())) ]
            , div [ class "content" ]
                    [ Grid.container []
                      [ Grid.row [ Row.topXs ]
                        [ Grid.col []
                          [ h1 [] [ text (t "title") ]
                            , span [ class "explanation" ]
                              [ text (I18n.get translation "aboutPage-description") ]
                          ]
                        ]
                      ]
                    ]
            , viewFooter navbarState
                |> Html.map (\_ -> ())
            ]
