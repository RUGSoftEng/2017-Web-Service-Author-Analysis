module Main exposing (main)

{-|
This file wires all parts of the app together.
-}

import Html exposing (Html)
import Http
import Bootstrap.Navbar as Navbar


-- import View
-- import Update

import Ports


-- import Types exposing (Model, Msg(NavbarMsg, UrlChange, AddFile, AttributionMsg), Bar(..))

import Navigation exposing (Location)
import Task exposing (Task)


-- import InputField
-- import Attribution.Update as Attribution

import Pages.Home as Home
import Pages.Attribution as Attribution
import Pages.AttributionPrediction as AttributionPrediction
import Views.Page as Page
import Data.File exposing (File)
import Route exposing (Route)


type alias PageLoadError =
    Http.Error


main : Program Never Model Msg
main =
    Navigation.program (Route.fromLocation >> SetRoute)
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }


type Page
    = Home
    | Attribution Attribution.Model
    | AttributionPrediction AttributionPrediction.Model
    | Profiling ()
    | Blank
    | NotFound


type PageState
    = Loaded Page
    | TransitioningFrom Page


getPage : PageState -> Page
getPage pagestate =
    case pagestate of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


type alias Model =
    { pageState : PageState, headerState : Navbar.State, footerState : Navbar.State }


type NavigationBar
    = HeaderBar
    | FooterBar


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( headerState, headerCmd ) =
            Navbar.initialState (NavbarMsg HeaderBar)

        ( footerState, footerCmd ) =
            Navbar.initialState (NavbarMsg FooterBar)

        ( model, routeCmd ) =
            { pageState = Loaded initialPage, headerState = headerState, footerState = footerState }
                |> setRoute (Route.fromLocation location)
    in
        ( model, Cmd.batch [ headerCmd, footerCmd, routeCmd ] )


initialPage : Page
initialPage =
    Blank


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.headerState model.footerState False page

        TransitioningFrom page ->
            viewPage model.headerState model.footerState False page


viewPage : Navbar.State -> Navbar.State -> Bool -> Page -> Html Msg
viewPage headerState footerState isLoading page =
    let
        frame =
            Page.frame headerState footerState isLoading (NavbarMsg HeaderBar) (NavbarMsg FooterBar)
    in
        case page of
            NotFound ->
                Html.text "page not found" |> frame (always NoOp) Nothing

            Blank ->
                -- displayed on initial page load, when other stuff is maybe still loading
                Html.text "We're blank" |> frame (always NoOp) Nothing

            Attribution subModel ->
                Attribution.view subModel
                    |> frame AttributionMsg Nothing

            AttributionPrediction subModel ->
                AttributionPrediction.view subModel
                    |> frame AttributionPredictionMsg Nothing

            Profiling _ ->
                Html.text "Profiling"
                    |> frame (always NoOp) Nothing

            Home ->
                Home.view
                    |> frame (always NoOp) Nothing


{-| Signals from the outside world that our app may want to respond to
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- fires when an item in the navbar is clicked
          -- this will change what item is highlighted
          Navbar.subscriptions model.headerState (NavbarMsg HeaderBar)
        , Navbar.subscriptions model.footerState (NavbarMsg FooterBar)
        , Ports.addFile AddFile
        , pageSubscriptions (getPage model.pageState)
        ]


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        Attribution subModel ->
            Attribution.subscriptions subModel
                |> Sub.map AttributionMsg

        _ ->
            Sub.none



--- UPDATE ---


type Msg
    = SetRoute (Maybe Route)
    | AttributionPredictionLoaded (Result PageLoadError AttributionPrediction.Model)
    | AttributionMsg Attribution.Msg
    | AttributionPredictionMsg AttributionPrediction.Msg
    | NavbarMsg NavigationBar Navbar.State
    | AddFile ( String, File )
    | NoOp


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition : (Result x a -> Msg) -> Task x a -> ( Model, Cmd Msg )
        transition toMsg task =
            ( { model | pageState = TransitioningFrom (getPage model.pageState) }
            , Task.attempt toMsg task
            )
    in
        case maybeRoute of
            Nothing ->
                ( { model | pageState = Loaded NotFound }
                , Cmd.none
                )

            Just (Route.Attribution) ->
                ( { model | pageState = Loaded (Attribution Attribution.init) }
                , Cmd.none
                )

            Just (Route.Profiling) ->
                ( model, Cmd.none )

            Just (Route.ProfilingPrediction) ->
                ( model, Cmd.none )

            Just (Route.AttributionPrediction) ->
                case getPage model.pageState of
                    Attribution attribution ->
                        transition AttributionPredictionLoaded (AttributionPrediction.init attribution)

                    AttributionPrediction page ->
                        ( model, Cmd.none )

                    _ ->
                        -- is really an error condition
                        ( model, Cmd.none )

            Just (Route.Home) ->
                ( { model | pageState = Loaded Home }
                , Cmd.none
                )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    case ( msg, page ) of
        ( SetRoute route, _ ) ->
            setRoute route model

        ( AddFile ( id, file ), Attribution subModel ) ->
            ( { model | pageState = Loaded (Attribution <| Attribution.addFile ( id, file ) subModel) }
            , Cmd.none
            )

        ( AttributionMsg subMsg, Attribution subModel ) ->
            let
                ( newSubModel, subCmd ) =
                    Attribution.update { readFiles = Ports.readFiles } subMsg subModel
            in
                ( { model | pageState = Loaded (Attribution newSubModel) }
                , Cmd.map AttributionMsg subCmd
                )

        ( AttributionPredictionMsg subMsg, AttributionPrediction subModel ) ->
            let
                newSubModel =
                    AttributionPrediction.update subMsg subModel
            in
                ( { model | pageState = Loaded (AttributionPrediction newSubModel) }
                , Cmd.none
                )

        ( AttributionPredictionLoaded (Ok attributionPrediction), _ ) ->
            ( { model | pageState = Loaded (AttributionPrediction attributionPrediction) }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )
