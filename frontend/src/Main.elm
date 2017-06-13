module Main exposing (main)

{-|
This file wires all parts of the app together.
-}

import Html exposing (Html)
import Dict
import Bootstrap.Navbar as Navbar
import Http
import Navigation exposing (Location)
import Task exposing (Task)


-- general config

import Ports
import Route exposing (Route)
import I18n exposing (Translations)


-- internal modules

import Pages.Home as Home
import Pages.Attribution as Attribution
import Pages.AttributionPrediction as AttributionPrediction
import Pages.Profiling as Profiling
import Pages.ProfilingPrediction as ProfilingPrediction
import Pages.AboutPage as AboutPage
import Views.Page as Page
import Data.File exposing (File)
import Config.Translations.English as English


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
    | Profiling Profiling.Model
    | ProfilingPrediction ProfilingPrediction.Model
    | AboutPage
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
    { pageState : PageState
    , headerState : Navbar.State
    , footerState : Navbar.State
    , translations : Translations
    , attributionRequest : RequestStatus
    , profilingRequest : RequestStatus
    }


{-| Type index for which navigation bar to update
-}
type NavigationBar
    = HeaderBar
    | FooterBar


{-| To cancel a request, we have to know what it's status is.

So, we have to manually set requests as InProgress when performed, and do some checking when receiving the result:
when the request is cancelled, just do nothing

Ideally we'd represent requests as subscriptions (using Http.progress), but then we can't use
tasks anymore to represent page loading.
-}
type RequestStatus
    = Idle
    | InProgress
    | Cancelled


cancelRequest : RequestStatus -> RequestStatus
cancelRequest status =
    case status of
        Idle ->
            Idle

        InProgress ->
            Cancelled

        Cancelled ->
            Cancelled


init : Location -> ( Model, Cmd Msg )
init location =
    let
        ( headerState, headerCmd ) =
            Navbar.initialState (NavbarMsg HeaderBar)

        ( footerState, footerCmd ) =
            Navbar.initialState (NavbarMsg FooterBar)

        ( model, routeCmd ) =
            { pageState = Loaded initialPage
            , headerState = headerState
            , footerState = footerState
            , translations = English.translations
            , attributionRequest = Idle
            , profilingRequest = Idle
            }
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
            viewPage model.headerState model.footerState model.translations False page

        TransitioningFrom page ->
            let
                _ =
                    Debug.log "is loading " page
            in
                viewPage model.headerState model.footerState model.translations True page


viewPage : Navbar.State -> Navbar.State -> Translations -> Bool -> Page -> Html Msg
viewPage headerState footerState translations isLoading page =
    let
        frameConfig contentMsg transition content =
            { headerState = headerState
            , footerState = footerState
            , headerMsg = NavbarMsg HeaderBar
            , footerMsg = NavbarMsg FooterBar
            , contentMsg = contentMsg
            , content = content
            , transition = transition
            , t = I18n.get translations.general
            }
    in
        case page of
            NotFound ->
                Html.text "page not found"
                    |> frameConfig (always NoOp) Nothing
                    |> Page.frame

            Blank ->
                -- displayed on initial page load, when other stuff is maybe still loading
                Html.text "We're blank"
                    |> frameConfig (always NoOp) Nothing
                    |> Page.frame

            Attribution subModel ->
                let
                    translation =
                        translations.attribution
                            |> Dict.union translations.input
                            |> Dict.union translations.language
                            |> Dict.union translations.genre
                in
                    if isLoading then
                        Attribution.loading translation subModel
                            |> frameConfig AttributionMsg Nothing
                            |> Page.frame
                    else
                        Attribution.view translation subModel
                            |> frameConfig AttributionMsg Nothing
                            |> Page.frame

            AttributionPrediction subModel ->
                let
                    translation =
                        translations.attributionPrediction
                            |> Dict.union translations.attributionPlots
                in
                    AttributionPrediction.view (I18n.get translation) subModel
                        |> frameConfig AttributionPredictionMsg Nothing
                        |> Page.frame

            Profiling subModel ->
                let
                    translation =
                        translations.profiling
                            |> Dict.union translations.input
                            |> Dict.union translations.language
                in
                    if isLoading then
                        Profiling.loading translation subModel
                            |> frameConfig ProfilingMsg Nothing
                            |> Page.frame
                    else
                        Profiling.view translation subModel
                            |> frameConfig ProfilingMsg Nothing
                            |> Page.frame

            ProfilingPrediction subModel ->
                let
                    translation =
                        translations.profilingPrediction
                            |> Dict.union translations.profilingPlots
                in
                    ProfilingPrediction.view (I18n.get translation) subModel
                        |> frameConfig ProfilingPredictionMsg Nothing
                        |> Page.frame

            Home ->
                let
                    translation =
                        translations.home |> Dict.union translations.general
                in
                    { content = Home.view translation
                    , contentMsg = always NoOp
                    , t = I18n.get translations.general
                    }
                        |> Page.homeFrame

            AboutPage ->
                let
                    translation =
                        translations.aboutPage |> Dict.union translations.general
                in
                    { content = AboutPage.view translation
                    , contentMsg = always NoOp
                    , t = I18n.get translations.general
                    }
                        |> Page.aboutPageFrame

{-| Signals from the outside world that our app may want to respond to

* Navbar.subscriptions: fire when an item in a navbar is clicked to highlight that item
* Ports.addFile: a file is sent from javascript
* pageSubscriptions: individual pages that have subscriptions
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
    | ProfilingPredictionLoaded (Result PageLoadError ProfilingPrediction.Model)
    | AttributionMsg Attribution.Msg
    | AttributionPredictionMsg AttributionPrediction.Msg
    | ProfilingMsg Profiling.Msg
    | ProfilingPredictionMsg ProfilingPrediction.Msg
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
                case getPage model.pageState of
                    AttributionPrediction { source } ->
                        -- retrieve the source from a prediction, and load that
                        ( { model | pageState = Loaded (Attribution source) }
                        , Cmd.none
                        )

                    Attribution subModel ->
                        -- navigating to the same page should cancel any ongoing request, and
                        -- keep the current page loaded.
                        ( { model
                            | attributionRequest = cancelRequest model.attributionRequest
                            , pageState = Loaded (getPage model.pageState)
                          }
                        , Cmd.none
                        )

                    _ ->
                        -- otherwise, load an empty attribution page
                        ( { model | pageState = Loaded (Attribution Attribution.init) }
                        , Cmd.none
                        )

            Just (Route.Profiling) ->
                case getPage model.pageState of
                    ProfilingPrediction { source } ->
                        ( { model | pageState = Loaded (Profiling source) }
                        , Cmd.none
                        )

                    Profiling subModel ->
                        -- navigating to the same page should cancel any ongoing request, and
                        -- keep the current page loaded.
                        ( { model
                            | profilingRequest = cancelRequest model.profilingRequest
                            , pageState = Loaded (getPage model.pageState)
                          }
                        , Cmd.none
                        )

                    _ ->
                        ( { model | pageState = Loaded (Profiling Profiling.init) }
                        , Cmd.none
                        )

            Just (Route.ProfilingPrediction) ->
                case getPage model.pageState of
                    Profiling profiling ->
                        ( { model
                            | pageState = TransitioningFrom (getPage model.pageState)
                            , profilingRequest = InProgress
                          }
                        , Task.attempt ProfilingPredictionLoaded (ProfilingPrediction.init profiling)
                        )

                    ProfilingPrediction page ->
                        ( model, Cmd.none )

                    _ ->
                        -- no prediction can be loaded/created, so navigate to profiling
                        navigateTo Route.Profiling model

            Just (Route.AttributionPrediction) ->
                case getPage model.pageState of
                    Attribution attribution ->
                        -- predict from attribution
                        ( { model
                            | pageState = TransitioningFrom (getPage model.pageState)
                            , attributionRequest = InProgress
                          }
                        , Task.attempt AttributionPredictionLoaded (AttributionPrediction.init attribution)
                        )

                    AttributionPrediction page ->
                        -- no change
                        ( model, Cmd.none )

                    _ ->
                        -- no prediction can be loaded/created, so navigate to attribution
                        navigateTo Route.Attribution model

            Just (Route.Home) ->
                ( { model | pageState = Loaded Home }
                , Cmd.none
                )

            Just (Route.AboutPage) ->
                ( { model | pageState = Loaded AboutPage }
                , Cmd.none
                )


{-| change the route AND the url explicitly

Most of the time this is not what you want. In some cases though,
we can only meaningfully load a page when some data is present, and
we need to redirect when that data is not present.

For instance, when the /attribution/prediction page is reloaded, there is no
prediction data, so we redirect to /attribution and let the user input their data.
-}
navigateTo : Route.Route -> Model -> ( Model, Cmd Msg )
navigateTo route model =
    let
        ( newModel, cmd ) =
            update (SetRoute <| Just Route.Attribution) model
    in
        ( newModel, Cmd.batch [ cmd, Route.modifyUrl route ] )


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

        ( ProfilingMsg subMsg, Profiling subModel ) ->
            let
                ( newSubModel, subCmd ) =
                    Profiling.update { readFiles = Ports.readFiles } subMsg subModel
            in
                ( { model | pageState = Loaded (Profiling newSubModel) }
                , Cmd.map ProfilingMsg subCmd
                )

        ( AttributionPredictionLoaded (Ok attributionPrediction), _ ) ->
            if model.attributionRequest == Cancelled then
                ( { model | attributionRequest = Idle }
                , Cmd.none
                )
            else
                ( { model
                    | pageState = Loaded (AttributionPrediction attributionPrediction)
                    , attributionRequest = Idle
                  }
                , Cmd.none
                )

        ( ProfilingPredictionLoaded (Ok profilingPrediction), _ ) ->
            if model.profilingRequest == Cancelled then
                ( { model | profilingRequest = Idle }
                , Cmd.none
                )
            else
                ( { model
                    | pageState = Loaded (ProfilingPrediction profilingPrediction)
                    , profilingRequest = Idle
                  }
                , Cmd.none
                )

        _ ->
            ( model, Cmd.none )
