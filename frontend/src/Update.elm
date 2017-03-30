module Update exposing (update, initialState)

{-| Update

describes how the model and the world should change based on a message.

this file also contains the initial state, definition of http requests to the server,
and routing - what page to display based on the url.
-}

import Http
import Bootstrap.Navbar as Navbar
import UrlParser exposing (s, top)
import RemoteData exposing (RemoteData(..))
import Navigation
import Dict exposing (Dict)
import Types exposing (..)
import InputField exposing (OutMsg(..))
import Ports
import Process


{-| Convert a Url into a Route - the page that should be displayed
-}
route : Navigation.Location -> Maybe Route
route location =
    let
        routeParser : UrlParser.Parser (Route -> a) a
        routeParser =
            UrlParser.oneOf
                [ UrlParser.map Home top
                , UrlParser.map AttributionRoute (s "attribution")
                , UrlParser.map ProfilingRoute (s "profiling")
                ]
    in
        UrlParser.parsePath routeParser location


initialState : Navigation.Location -> ( Model, Cmd Msg )
initialState location =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg

        defaultAttribution =
            { knownAuthor = InputField.init
            , unknownAuthor = InputField.init
            , result = NotAsked
            , language = EN
            , languages = [ EN, NL ]
            , featureCombo = Combo4
            , featureCombos = [ Combo1, Combo4 ]
            }

        defaultProfiling =
            { input = InputField.init
            , result = Just { gender = M, age = 20 }
            }

        defaultRoute =
            route location
                |> Maybe.withDefault Home
    in
        ( { route = defaultRoute
          , navbarState = navbarState
          , profiling = defaultProfiling
          , attribution = defaultAttribution
          }
        , navbarCmd
        )


{-| How our model should change when a message comes in

* NoOp, does nothing
* NavBarMsg, updates highlight in the navigation bar
* ChangeRoute, changes the route - the currently displayed page
* AddFile, receive a file from JS, put it in the correct place in the model
* UrlChange, does nothing, see comment
* AttributionMsg, nested update on the attribution
* ProfilingMsg, nested update on the profiling
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NavbarMsg state ->
            ( { model | navbarState = state }, Cmd.none )

        ChangeRoute newRoute ->
            if newRoute == model.route then
                ( model, Cmd.none )
            else
                let
                    _ =
                        Debug.log "new route" newRoute

                    newUrl =
                        case newRoute of
                            Home ->
                                "/"

                            AttributionRoute ->
                                "attribution"

                            ProfilingRoute ->
                                "profiling"
                in
                    ( { model | route = newRoute }
                      -- update the url to represent the currently displayed page.
                    , Navigation.newUrl newUrl
                    )

        AddFile ( id, file ) ->
            -- We get a File and the id of the destination. Based on that ID, we create a Msg to get the file
            -- to the destination (either in AttributionState or ProfilingState).
            -- then we call update (recursively) to execute the Msg we created
            -- flip reverses the order of arguments, so `flip (-) 12 4 == (-) 4 12 == 4 - 12 == -8`.
            case id of
                "KnownAuthor" ->
                    InputField.addFile file
                        |> AttributionInputField KnownAuthor
                        |> AttributionMsg
                        |> flip update model

                "UnknownAuthor" ->
                    InputField.addFile file
                        |> AttributionInputField UnknownAuthor
                        |> AttributionMsg
                        |> flip update model

                "Profiling" ->
                    InputField.addFile file
                        |> ProfilingInputField
                        |> ProfilingMsg
                        |> flip update model

                _ ->
                    -- throws a javascript error
                    Debug.crash <| "trying to add a file to " ++ id ++ ", but it does not exist!"

        UrlChange location ->
            {- nothing happens here
               Any url change made by the user will result in a reload from the server. Reaction is irrelevant
               Any url change made by elm is the result of a route change. Reaction to that change will lead to infinite cycles
               kept for documentation purposes.
            -}
            ( model, Cmd.none )

        AttributionMsg msg ->
            -- performs a nested update on the attribution
            let
                ( newAttribution, attributionCommands ) =
                    updateAttribution msg model.attribution
            in
                ( { model | attribution = newAttribution }
                , Cmd.map AttributionMsg attributionCommands
                )

        ProfilingMsg msg ->
            -- performs a nested update on the profiling
            let
                ( newProfiling, profilingCommands ) =
                    updateProfiling msg model.profiling
            in
                ( { model | profiling = newProfiling }
                , Cmd.map ProfilingMsg profilingCommands
                )


updateProfiling : ProfilingMessage -> ProfilingState -> ( ProfilingState, Cmd ProfilingMessage )
updateProfiling msg profiling =
    case msg of
        UploadAuthorProfiling ->
            ( profiling, Cmd.none )

        ProfilingInputField msg ->
            let
                ( newInput, inputCommands, inputOutMsg ) =
                    InputField.update msg profiling.input

                outCmd =
                    case inputOutMsg of
                        Nothing ->
                            Cmd.none

                        Just ListenForFiles ->
                            Ports.readFiles ( "profiling-file-input", "Profiling" )
            in
                ( { profiling | input = newInput }
                , Cmd.batch
                    [ outCmd
                    , Cmd.map ProfilingInputField inputCommands
                    ]
                )


updateAttribution : AttributionMessage -> AttributionState -> ( AttributionState, Cmd AttributionMessage )
updateAttribution msg attribution =
    case msg of
        PerformAttribution ->
            let
                newresult =
                    Loading
            in
                ( { attribution | result = newresult }, performAttribution attribution )

        CancelAttribution ->
            let
                newresult =
                    NotAsked
            in
                ( { attribution | result = newresult }, Cmd.none {- cancelAttribution attribution -} )

        ServerResponse response ->
            ( { attribution | result = RemoteData.fromResult response }, Cmd.none )

        AttributionInputField KnownAuthor msg ->
            let
                ( newInput, inputCommands, inputOutMsg ) =
                    InputField.update msg attribution.knownAuthor

                outCmd =
                    case inputOutMsg of
                        Nothing ->
                            Cmd.none

                        Just ListenForFiles ->
                            Ports.readFiles ( "attribution-known-author-file-input", "KnownAuthor" )
            in
                ( { attribution | knownAuthor = newInput }
                , Cmd.batch
                    [ outCmd
                    , Cmd.map (AttributionInputField KnownAuthor) inputCommands
                    ]
                )

        AttributionInputField UnknownAuthor msg ->
            let
                ( newInput, inputCommands, inputOutMsg ) =
                    InputField.update msg attribution.unknownAuthor

                outCmd =
                    case inputOutMsg of
                        Nothing ->
                            Cmd.none

                        Just ListenForFiles ->
                            Ports.readFiles ( "attribution-unknown-author-file-input", "UnknownAuthor" )
            in
                ( { attribution | unknownAuthor = newInput }
                , Cmd.batch
                    [ outCmd
                    , Cmd.map (AttributionInputField UnknownAuthor) inputCommands
                    ]
                )

        SetLanguage newLanguage ->
            ( { attribution | language = newLanguage }
            , Cmd.none
            )

        SetFeatureCombo newFeatureCombo ->
            ( { attribution | featureCombo = newFeatureCombo }
            , Cmd.none
            )


{-| describes the action of sending the attribution state to the server and receiving a response
-}
performAttribution : AttributionState -> Cmd AttributionMessage
performAttribution attribution =
    let
        body =
            Http.jsonBody (encodeAttributionRequest attribution)

        result =
            Loading
    in
        Http.post (webserverUrl ++ authorRecognitionEndpoint) body decodeAttributionResponse
            |> Http.send ServerResponse



{-
   cancelAttribution : AttributionState
   cancelAttribution attribution =
     ( Process.kill id )
-}


webserverUrl : String
webserverUrl =
    "http://localhost:8080"


authorRecognitionEndpoint : String
authorRecognitionEndpoint =
    "/api/attribution"
