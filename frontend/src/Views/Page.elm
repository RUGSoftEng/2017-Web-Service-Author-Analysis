module Views.Page exposing (..)

import Bootstrap.Navbar as Navbar
import Html exposing (Html, div, a, text, img, header, footer, h1)
import Html.Attributes exposing (class, style, src, href, id, attribute)
import Route
import Views.Spinner exposing (spinner)


(=>) =
    (,)


frame : Navbar.State -> Navbar.State -> Bool -> (Navbar.State -> msg) -> (Navbar.State -> msg) -> (submsg -> msg) -> Maybe (Html submsg) -> Html submsg -> Html msg
frame headerState footerState isLoading headerMsg footerMsg wrapper transition content =
    div [ class "maincontainer" ]
        [ viewHeader headerState isLoading |> Html.map headerMsg
        , content |> Html.map wrapper
        , viewFooter footerState |> Html.map footerMsg
        ]


homeFrame : Navbar.State -> Navbar.State -> (Navbar.State -> msg) -> (Navbar.State -> msg) -> (submsg -> msg) -> Maybe (Html submsg) -> Html submsg -> Html msg
homeFrame headerState footerState headerMsg footerMsg wrapper transition content =
    content |> Html.map wrapper



{-
   div [ class "maincontainer" ]
       [ viewHomeHeader headerState |> Html.map headerMsg
       , content |> Html.map wrapper
       , viewFooter footerState |> Html.map footerMsg
       ]
-}


mainNav : (Navbar.State -> msg) -> Navbar.State -> Html msg
mainNav toMsg navbarState =
    div [ class "navbar fixed", id "main-nav", attribute "role" "banner", attribute "style" "min-height: 76px;" ]
        [ div [ class "container" ]
            [ Navbar.config toMsg
                |> Navbar.attrs [ id "main-nav", class "fixed" ]
                |> Navbar.brand [ href "#" ] [ text "Author Analysis" ]
                |> Navbar.customItems
                    [ Navbar.customItem <| a [ class "pull-right", Route.href Route.Attribution ] [ text "Attribution" ]
                    , Navbar.customItem <| a [ class "pull-right", Route.href Route.Profiling ] [ text "Profiling" ]
                    ]
                |> Navbar.view navbarState
            ]
        ]


{-| The navigation bar at the top
-}
viewHeader : Navbar.State -> Bool -> Html Navbar.State
viewHeader navbarState isLoading =
    header [ class "header", id "home", attribute "style" "min-height: 76px;" ] [ mainNav identity navbarState ]


viewHomeHeader : Navbar.State -> Html Navbar.State
viewHomeHeader navbarState =
    header [ id "home", class "header" ]
        [ div [ class "container" ]
            [ Navbar.config identity
                |> Navbar.brand [ Route.href Route.Home ] [ text "Author Analysis " ]
                |> Navbar.customItems
                    [ Navbar.customItem <| a [ class "pull-right", Route.href Route.Attribution ] [ text "Attribution" ]
                    , Navbar.customItem <| a [ class "pull-right", Route.href Route.Profiling ] [ text "Profiling" ]
                    ]
                |> Navbar.lightCustomClass ""
                |> Navbar.view navbarState
            ]
        , div [ class "home-header-wrap" ]
            [ div [ class "header-content-wrap" ]
                [ div [ class "container" ]
                    [ h1 [ class "intro-text" ] [ text "Author Analysis" ]
                    ]
                ]
            , div [ class "clear" ] []
            ]
        ]


{-| The bar at the bottom, this is a modified navigation bar
-}
viewFooter : Navbar.State -> Html Navbar.State
viewFooter footerbarState =
    footer []
        [ div [ class "container" ]
            [ Navbar.config identity
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
                |> Navbar.lightCustomClass ""
                |> Navbar.view footerbarState
            ]
        ]


viewIf predicate html =
    if predicate then
        html
    else
        text ""
