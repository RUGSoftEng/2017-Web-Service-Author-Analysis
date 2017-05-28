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
                [ Grid.col [ textCenter ]
                    [ span [] [ text "Attribution" ]
                    ]
                , Grid.col [ textCenter ]
                    [ span [] [ text "Profiling" ]
                    ]
                ]
            ]
        , footer [ id "footer" ]
            [ div [ class "container" ]
                [ div [ class "col-md-3 company-details" ]
                    [ div [ class "icon-top red-text" ]
                        [ img [ alt "", src "https://demot-vertigostudio.netdna-ssl.com/zerif-lite/wp-content/uploads/sites/51/2017/04/map25-redish.png" ]
                            []
                        ]
                    , div [ class "zerif-footer-address" ]
                        [ text "San Francisco - Adress - 18 California Street 1100." ]
                    ]
                ]
            ]
        ]


view_ : Translation -> Html msg
view_ translation =
    let
        t key =
            I18n.get translation key
    in
        div [ id "home", class "content" ]
            [ Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ Grid.col []
                        [ h1 [] [ text "Features" ]
                        , text "subtitle"
                        ]
                    ]
                , Grid.row []
                    [ Grid.col [ textCenter, Col.lg3, Col.sm3 ]
                        [ text "system A"
                        , i
                            [ style
                                [ ( "background", "url(https://demot-vertigostudio.netdna-ssl.com/zerif-lite/wp-content/uploads/sites/51/2015/05/ti-logo.png) no-repeat center" )
                                , ( "width", "100%" )
                                , ( "height", "100%" )
                                , ( "display", "block" )
                                ]
                            ]
                            []
                        ]
                    , Grid.col [ textCenter, Col.lg3, Col.sm3 ] [ text "system B" ]
                    ]
                ]
            ]
