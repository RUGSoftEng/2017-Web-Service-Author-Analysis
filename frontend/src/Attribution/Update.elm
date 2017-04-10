module Attribution.Update exposing (update, initialState, subscriptions)

{-| Initial state, update and subscriptions for the Attribution page

We're jumping through some hoops to keep this page as simple as possible.

We're not handling the HTTP requests on this page(what to send, what to receive). Instead, both
the `Msg` and `Model` are parameterized over the result we get back from the server.
This is the lowercase `result` that you see in the type annotations.

A further consequence is that the update function takes a `performAttribution` function as its argument,
which handles the actual http stuff. This function is implemented by the caller. The technical term for this
is dependency injection.

-}

import Dict
import RemoteData exposing (RemoteData(..))


--

import Ports
import Attribution.Types exposing (..)
import Attribution.Plots as Plots
import InputField exposing (OutMsg(..))
import InputField
import PlotSlideShow


initialState : Model
initialState =
    { knownAuthor = InputField.init
    , unknownAuthor = InputField.init
    , result = NotAsked
    , language = EN
    , languages = [ EN, NL ]
    , featureCombo = Combo4
    , featureCombos = [ Combo1, Combo4 ]
    , plotState =
        case Dict.keys Plots.plots of
            [] ->
                -- TODO make this safe
                Debug.crash "No plots to be displayed"

            x :: xs ->
                PlotSlideShow.initialState x xs
    }


update : (Model -> Cmd Msg) -> Msg -> Model -> ( Model, Cmd Msg )
update performAttribution msg attribution =
    case msg of
        PerformAttribution ->
            ( { attribution | result = Loading }, performAttribution attribution )

        ServerResponse response ->
            ( { attribution | result = response }, Cmd.none )

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

        AttributionStatisticsMsg statisticsMsg ->
            ( { attribution | plotState = PlotSlideShow.update statisticsMsg attribution.plotState }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ InputField.subscriptions model.knownAuthor
            |> Sub.map (AttributionInputField KnownAuthor)
        , InputField.subscriptions model.unknownAuthor
            |> Sub.map (AttributionInputField UnknownAuthor)
        ]
