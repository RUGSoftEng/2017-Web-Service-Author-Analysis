module Views.Page exposing (..)

import Bootstrap.Navbar as Navbar
import Utils exposing ((=>))
import Html exposing (Html, div, a, text, img, header, footer, h1)
import Html.Attributes exposing (class, style, src, href, id, attribute)
import Route
import I18n exposing (Translator)


type alias FrameConfig submsg msg =
    { headerState : Navbar.State
    , footerState : Navbar.State
    , headerMsg : Navbar.State -> msg
    , footerMsg : Navbar.State -> msg
    , contentMsg : submsg -> msg
    , transition : Maybe (Html submsg)
    , content : Html submsg
    , t : Translator
    }


frame : FrameConfig submsg msg -> Html msg
frame { headerState, footerState, headerMsg, footerMsg, contentMsg, transition, content, t } =
    div [ class "maincontainer" ]
        [ viewHeader t headerState |> Html.map headerMsg
        , content |> Html.map contentMsg
        , viewFooter footerState |> Html.map footerMsg
        ]


homeFrame : { a | content : Html submsg, contentMsg : submsg -> msg, t : Translator } -> Html msg
homeFrame { content, contentMsg } =
    content |> Html.map contentMsg


mainNav : Translator -> (Navbar.State -> msg) -> Navbar.State -> Html msg
mainNav t toMsg navbarState =
    div [ class "navbar fixed", id "main-nav", attribute "role" "banner", attribute "style" "min-height: 76px;" ]
        [ div [ class "container" ]
            [ Navbar.config toMsg
                |> Navbar.attrs [ id "main-nav", class "fixed" ]
                |> Navbar.brand [ href "#" ] [ text (t "author-analysis") ]
                |> Navbar.customItems
                    [ Navbar.customItem <| a [ class "pull-right", Route.href Route.Attribution ] [ text (t "attribution") ]
                    , Navbar.customItem <| a [ class "pull-right", Route.href Route.Profiling ] [ text (t "profiling") ]
                    ]
                |> Navbar.view navbarState
            ]
        ]


{-| The navigation bar at the top
-}
viewHeader : Translator -> Navbar.State -> Html Navbar.State
viewHeader translator navbarState =
    header [ class "header", id "home", attribute "style" "min-height: 76px;" ] [ mainNav translator identity navbarState ]


viewHomeHeader : Translator -> Navbar.State -> Html Navbar.State
viewHomeHeader t navbarState =
    header [ id "home", class "header" ]
        [ div [ class "container" ]
            [ Navbar.config identity
                |> Navbar.brand [ Route.href Route.Home ] [ text (t "author-analysis") ]
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


viewIf : Bool -> Html msg -> Html msg
viewIf predicate html =
    if predicate then
        html
    else
        text ""
