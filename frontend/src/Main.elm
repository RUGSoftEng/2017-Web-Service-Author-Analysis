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
import Process
import Time


-- import InputField
-- import Attribution.Update as Attribution

import Pages.Home as Home
import Pages.Attribution as Attribution
import Pages.AttributionPrediction as AttributionPrediction
import Pages.Profiling as Profiling
import Views.Page as Page
import Data.File exposing (File)
import Route exposing (Route)
import I18n exposing (Translations)


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


cancelRequest : Status -> Status
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
            , translations = I18n.english
            , attributionRequest = Idle
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
                let
                    customFrame =
                        Page.frame headerState footerState False (NavbarMsg HeaderBar) (NavbarMsg FooterBar)
                in
                    if isLoading then
                        Attribution.loading translations.attribution subModel
                            |> customFrame AttributionMsg Nothing
                    else
                        Attribution.view translations.attribution subModel
                            |> customFrame AttributionMsg Nothing

            AttributionPrediction subModel ->
                AttributionPrediction.view subModel
                    |> frame AttributionPredictionMsg Nothing

            Profiling subModel ->
                Profiling.view translations.profiling subModel
                    |> frame ProfilingMsg Nothing

            Home ->
                Home.view
                    |> frame (always NoOp) Nothing


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
    | AttributionMsg Attribution.Msg
    | AttributionPredictionMsg AttributionPrediction.Msg
    | ProfilingMsg Profiling.Msg
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
                ( { model | pageState = Loaded (Profiling Profiling.init) }
                , Cmd.none
                )

            Just (Route.ProfilingPrediction) ->
                ( model, Cmd.none )

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
                ( { model | pageState = Loaded (AttributionPrediction attributionPrediction) }
                , Cmd.none
                )

        _ ->
            ( model, Cmd.none )
