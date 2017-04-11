module Attribution.Update exposing (update, Config, initialState, subscriptions)

{-| Initial state, update and subscriptions for the Attribution page

We're not handling the HTTP requests on this page(what to send, what to receive).
Instead, the update function takes a `performAttribution` function as its argument,
which handles the actual http stuff. This function is implemented by the caller. The technical term for this
is dependency injection.

-}

import Dict
import RemoteData exposing (RemoteData(..))


--

import Attribution.Types exposing (..)
import Attribution.Plots as Plots
import InputField exposing (OutMsg(..))
import PlotSlideShow


{-| Initial state of the Attribution page

initializes two empty authors, sets defaults for language and combos + keeps
track of the available options for these values.

The result is a WebData, defined as

type alias WebData value = RemoteData Http.Error value

type RemoteData err value
    = Success value
    | Failure error
    | NotAsked
    | Loading

We've not asked for the result (of attribution) initially.
When requesting, the value is set to loading. The Http request can
then either set it to Success or Failure. When requesting again, the
value is set to `Loading` and so the cycle continues.

More info, see http://blog.jenkster.com/2016/06/how-elm-slays-a-ui-antipattern.html

Finally the plotState stores the ids (in this case labels) of the available plots.
The used data structure cannot express "emptyness", but we cannot prove to the compiler that Plots.plots is not empty.

So we have to be naughty and use the escape hatch `Debug.crash`. Debug.crash has value `String -> a`, which
means it will always satisfy the type checker and compile. When evaluated, Debug.crash will
bring the whole application down by throwing a javascript error.

We can know that this will never happen, because the Plots.plots value is currently defined with
at least one element.
-}
initialState : Model
initialState =
    { knownAuthor = InputField.init
    , unknownAuthor = InputField.init
    , language = EN
    , languages = [ EN, NL ]
    , featureCombo = Combo4
    , featureCombos = [ Combo1, Combo4 ]
    , result = NotAsked
    , plotState =
        case Dict.keys Plots.plots of
            [] ->
                -- TODO make this safe
                Debug.crash "No plots to be displayed"

            x :: xs ->
                PlotSlideShow.initialState x xs
    }


{-| external functions that we'll inject into the Attribution page

Both of these handle communication with the outside world. It's nicer
to bundle everything that does communication, keeping the separate pages ignorant.
-}
type alias Config =
    { performAttribution : Model -> Cmd Msg
    , readFiles : ( String, String ) -> Cmd Msg
    }


{-| Update the Attribution page

* PerformAttribution

    will use the `performAttribution` function from the config to request attribution
    with the current model.

* ServerResponse

    Put the response of attribution into the model

* InputFieldMsg

    Given a message for an InputField, update the correct input field with that message.
    Then put everything back in the model and execute any commands that InputField.update may have returned.

* PlotSlideShowMsg
    Given a message for an SlideShowPlot , update the correct input field with that message.
    Then put everything back in the model and execute any commands that SlideShowPlot.update may have returned.

The other three messages are simple setters of data.
-}
update : Config -> Msg -> Model -> ( Model, Cmd Msg )
update config msg attribution =
    case msg of
        PerformAttribution ->
            ( { attribution | result = Loading }, config.performAttribution attribution )

        ServerResponse response ->
            ( { attribution | result = response }, Cmd.none )

        InputFieldMsg KnownAuthor msg ->
            let
                ( newInput, inputCommands, inputOutMsg ) =
                    InputField.update msg attribution.knownAuthor

                outCmd =
                    case inputOutMsg of
                        Nothing ->
                            Cmd.none

                        Just ListenForFiles ->
                            config.readFiles ( "attribution-known-author-file-input", "KnownAuthor" )
            in
                ( { attribution | knownAuthor = newInput }
                , Cmd.batch
                    [ outCmd
                    , Cmd.map (InputFieldMsg KnownAuthor) inputCommands
                    ]
                )

        InputFieldMsg UnknownAuthor msg ->
            let
                ( newInput, inputCommands, inputOutMsg ) =
                    InputField.update msg attribution.unknownAuthor

                outCmd =
                    case inputOutMsg of
                        Nothing ->
                            Cmd.none

                        Just ListenForFiles ->
                            config.readFiles ( "attribution-unknown-author-file-input", "UnknownAuthor" )
            in
                ( { attribution | unknownAuthor = newInput }
                , Cmd.batch
                    [ outCmd
                    , Cmd.map (InputFieldMsg UnknownAuthor) inputCommands
                    ]
                )

        PlotSlideShowMsg statisticsMsg ->
            ( { attribution | plotState = PlotSlideShow.update statisticsMsg attribution.plotState }
            , Cmd.none
            )

        SetLanguage newLanguage ->
            ( { attribution | language = newLanguage }
            , Cmd.none
            )

        SetFeatureCombo newFeatureCombo ->
            ( { attribution | featureCombo = newFeatureCombo }
            , Cmd.none
            )


{-| Subscriptions for the animation of FileInput's cards, used for the file upload UI.
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ InputField.subscriptions model.knownAuthor
            |> Sub.map (InputFieldMsg KnownAuthor)
        , InputField.subscriptions model.unknownAuthor
            |> Sub.map (InputFieldMsg UnknownAuthor)
        ]
