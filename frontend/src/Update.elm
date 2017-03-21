module Update exposing (update, initialState)

import Http
import Bootstrap.Navbar as Navbar
import UrlParser exposing (s, top)
import Navigation
import Types exposing (..)


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
            { knownAuthorMode = PasteText
            , knownAuthorText = ""
            , unknownAuthorMode = PasteText
            , unknownAuthorText = ""
            , result = Nothing
            , language = EN
            }

        defaultProfiling =
            { mode = PasteText
            , text = fillerText1
            , result = Just { gender = M, age = 20 }
            }

        defaultRoute =
            route location
                -- default to attribution during development, so that
                -- we don't have to switch pages (from home) to see results
                |>
                    Maybe.withDefault AttributionRoute
    in
        ( { route = defaultRoute
          , navbarState = navbarState
          , profiling = defaultProfiling
          , attribution = defaultAttribution
          }
        , navbarCmd
        )


toggleInputMode : InputMode -> InputMode
toggleInputMode mode =
    case mode of
        FileUpload ->
            PasteText

        PasteText ->
            FileUpload


{-| How our model should change when a message comes in

* NoOp, does nothing
* NavBarMsg, updates highlight in the navigation bar
* ChangeRoute, changes the route - the currently displayed page
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

        UrlChange location ->
            {- nothing happends here
               Any url change made by the user will result in a reload from the server. Reaction is irrelevant
               Any url change made by elm is the result of a route change. Reaction to that change will lead to infinite cycles
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
        ToggleProfilingInputMode ->
            ( { profiling | mode = toggleInputMode profiling.mode }
            , Cmd.none
            )

        SetProfilingText newText ->
            ( { profiling | text = newText }
            , Cmd.none
            )

        UploadAuthorProfiling ->
            -- currently not implemented
            ( profiling, Cmd.none )


updateAttribution : AttributionMessage -> AttributionState -> ( AttributionState, Cmd AttributionMessage )
updateAttribution msg attribution =
    case msg of
        PerformAttribution ->
            ( attribution, performAttribution attribution )

        ServerResponse response ->
            case response of
                Err error ->
                    ( attribution, Cmd.none )

                Ok fromServer ->
                    ( { attribution | result = Just fromServer }
                    , Cmd.none
                    )

        ToggleInputMode KnownAuthor ->
            ( { attribution | knownAuthorMode = toggleInputMode attribution.knownAuthorMode }
            , Cmd.none
            )

        ToggleInputMode UnknownAuthor ->
            ( { attribution | unknownAuthorMode = toggleInputMode attribution.unknownAuthorMode }
            , Cmd.none
            )

        SetText KnownAuthor newText ->
            ( { attribution | knownAuthorText = newText }
            , Cmd.none
            )

        SetText UnknownAuthor newText ->
            ( { attribution | unknownAuthorText = newText }
            , Cmd.none
            )

        SetLanguage newLanguage ->
            ( { attribution | language = newLanguage }
            , Cmd.none
            )


{-| describes the action of sending the attribution state to the server and receiving a response
-}
performAttribution : AttributionState -> Cmd AttributionMessage
performAttribution attribution =
    let
        toServer =
            { knownAuthorText = attribution.knownAuthorText, unknownAuthorText = attribution.unknownAuthorText }

        body =
            Http.jsonBody (encodeToServer toServer)
    in
        Http.post (webserverUrl ++ authorRecognitionEndpoint) body decodeAttributionResponse
            |> Http.send ServerResponse


webserverUrl : String
webserverUrl =
    "http://localhost:8080"


authorRecognitionEndpoint : String
authorRecognitionEndpoint =
    "/api/attribution"


fillerText1 =
    """Leverage agile frameworks to provide a robust synopsis for high level overviews. Iterative approaches to corporate strategy foster collaborative thinking to further the overall value proposition. Organically grow the holistic world view of disruptive innovation via workplace diversity and empowerment.
"""


fillerText2 =
    """This is the update of Unknown Author.
"""
