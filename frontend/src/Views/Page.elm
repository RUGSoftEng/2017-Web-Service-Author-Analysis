module Views.Page exposing (..)

import Bootstrap.Navbar as Navbar
import Html exposing (Html, div, a, text, img, header, footer)
import Html.Attributes exposing (class, style, src, href)
import Route


(=>) =
    (,)


frame : Navbar.State -> Navbar.State -> Bool -> (Navbar.State -> msg) -> (Navbar.State -> msg) -> (submsg -> msg) -> Maybe (Html submsg) -> Html submsg -> Html msg
frame headerState footerState isLoading headerMsg footerMsg wrapper transition content =
    div [ class "maincontainer" ]
        [ viewHeader headerState |> Html.map headerMsg
        , content |> Html.map wrapper
        , viewFooter footerState |> Html.map footerMsg
        ]


{-| The navigation bar at the top
-}
viewHeader : Navbar.State -> Html Navbar.State
viewHeader navbarState =
    header []
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
