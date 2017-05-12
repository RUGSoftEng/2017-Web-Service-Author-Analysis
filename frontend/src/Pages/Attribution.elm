module Pages.Attribution exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder, checked)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col


--

import Data.Attribution.Input exposing (..)
import Data.Attribution.Genre as Genre exposing (Genre)
import Data.File exposing (File)
import Data.Language as Language exposing (Language(..))
import Config.Attribution as Config
import InputField
import Route
import I18n exposing (Translation)
import Examples exposing (sameAuthor, differentAuthor)


type alias Model =
    Data.Attribution.Input.Input


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
init : Model
init =
    { knownAuthor = InputField.init
    , unknownAuthor = InputField.init
    , language = Config.defaultLanguage
    , languages = Config.availableLanguages
    , genre = Config.defaultGenre Config.defaultLanguage
    , featureCombo = Combo4
    , featureCombos = [ Combo1, Combo4 ]
    }


{-| external functions that we'll inject into the Attribution page

Both of these handle communication with the outside world. It's nicer
to bundle everything that does communication, keeping the separate pages ignorant.
-}
type alias Config msg =
    { readFiles : ( String, String ) -> Cmd msg
    }


type Example
    = DifferentAuthor
    | SameAuthor


type Msg
    = SetLanguage Language
    | SetFeatureCombo FeatureCombo
    | SetGenre Genre
    | InputFieldMsg Author InputField.Msg
    | LoadExample Example


{-| Update the Attribution page
* InputFieldMsg
    Given a message for an InputField, update the correct input field with that message.
    Then put everything back in the model and execute any commands that InputField.update may have returned.
The other three messages are simple setters of data.
-}
update : Config InputField.Msg -> Msg -> Model -> ( Model, Cmd Msg )
update config msg attribution =
    case msg of
        InputFieldMsg KnownAuthor msg ->
            let
                updateConfig : InputField.UpdateConfig
                updateConfig =
                    { readFiles = config.readFiles ( "attribution-known-author-file-input", "KnownAuthor" )
                    }

                ( newInput, inputCommands ) =
                    InputField.update updateConfig msg attribution.knownAuthor
            in
                ( { attribution | knownAuthor = newInput }
                , Cmd.map (InputFieldMsg KnownAuthor) inputCommands
                )

        InputFieldMsg UnknownAuthor msg ->
            let
                updateConfig : InputField.UpdateConfig
                updateConfig =
                    { readFiles = config.readFiles ( "attribution-unknown-author-file-input", "UnknownAuthor" )
                    }

                ( newInput, inputCommands ) =
                    InputField.update updateConfig msg attribution.unknownAuthor
            in
                ( { attribution | unknownAuthor = newInput }
                , Cmd.map (InputFieldMsg UnknownAuthor) inputCommands
                )

        SetLanguage newLanguage ->
            ( { attribution | language = newLanguage }
            , Cmd.none
            )

        SetFeatureCombo newFeatureCombo ->
            ( { attribution | featureCombo = newFeatureCombo }
            , Cmd.none
            )

        SetGenre genre ->
            ( { attribution | genre = genre }
            , Cmd.none
            )

        LoadExample SameAuthor ->
            ( { attribution
                | knownAuthor = InputField.fromString sameAuthor.knownAuthor
                , unknownAuthor = InputField.fromString sameAuthor.unknownAuthor
              }
            , Cmd.none
            )

        LoadExample DifferentAuthor ->
            ( { attribution
                | knownAuthor = InputField.fromString differentAuthor.knownAuthor
                , unknownAuthor = InputField.fromString differentAuthor.unknownAuthor
              }
            , Cmd.none
            )


addFile : ( String, File ) -> Model -> Model
addFile ( identifier, file ) attribution =
    case identifier of
        "KnownAuthor" ->
            { attribution | knownAuthor = InputField.addFile file attribution.knownAuthor }

        "UnknownAuthor" ->
            { attribution | unknownAuthor = InputField.addFile file attribution.unknownAuthor }

        _ ->
            Debug.crash <| "File with invalid id `" ++ identifier ++ "` cannot be added"


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



-- View


view : Translation -> Model -> Html Msg
view translation attribution =
    let
        t key =
            I18n.get translation key
    in
        div [ class "content" ]
            [ Grid.container []
                [ Grid.row [ Row.topXs ]
                    [ Grid.col []
                        [ h1 [] [ text "Attribution" ]
                        , span [ class "explanation" ] [ text (t "explanation") ]
                        ]
                    ]
                , Grid.row [ Row.attrs [ class "boxes" ] ]
                    [ knownAuthorInput t attribution.knownAuthor
                    , unknownAuthorInput t attribution.unknownAuthor
                    ]
                , Grid.row []
                    [ Grid.col [ Col.attrs [ class "text-center box submission" ] ]
                        [ Button.linkButton [ Button.primary, Button.attrs [ Route.href Route.AttributionPrediction, id "compare-button" ] ] [ text "Compare!" ]
                        ]
                    ]
                , Grid.row []
                    [ Grid.col [ Col.attrs [ class "text-center" ] ]
                        [ Button.button [ Button.secondary, Button.attrs [ id "compare-button", onClick (LoadExample SameAuthor) ] ] [ text "Load Example - same authors" ]
                        , Button.button [ Button.secondary, Button.attrs [ id "compare-button", onClick (LoadExample DifferentAuthor) ] ] [ text "Load Example - different authors" ]
                        ]
                    ]
                , Grid.row [ Row.attrs [ class "boxes settings" ] ] (settings t attribution)
                ]
            ]


knownAuthorInput : (String -> String) -> InputField.Model -> Grid.Column Msg
knownAuthorInput t knownAuthor =
    let
        {- config for an InputField

           * label: UI name for this field
           * radioButtonName: internal `name` attribute for the radio buttons
           * fileInputId: id for the <input> element where files for this InputField are stored
           * multiple: can multiple files be uploaded at once
        -}
        config : InputField.ViewConfig
        config =
            { label = t "known-author-label"
            , radioButtonName = "attribution-known-author-buttons"
            , fileInputId = "attribution-known-author-file-input"
            , info = t "known-author-description"
            , multiple = True
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center box" ] ] <|
            (InputField.view config knownAuthor
                |> List.map (Html.map (InputFieldMsg KnownAuthor))
            )


unknownAuthorInput : (String -> String) -> InputField.Model -> Grid.Column Msg
unknownAuthorInput t unknownAuthor =
    let
        config : InputField.ViewConfig
        config =
            { label = t "unknown-author-label"
            , radioButtonName = "attribution-unknown-author-buttons"
            , fileInputId = "attribution-unknown-author-file-input"
            , info = t "unknown-author-description"
            , multiple = False
            }
    in
        Grid.col [ Col.md5, Col.attrs [ class "center-block text-center box" ] ] <|
            (InputField.view config unknownAuthor
                |> List.map (Html.map (InputFieldMsg UnknownAuthor))
            )


settings : (String -> String) -> Model -> List (Grid.Column Msg)
settings t attribution =
    let
        genres =
            Config.genres attribution.language

        languageRadio language =
            li []
                [ label []
                    [ input
                        [ type_ "radio"
                        , checked (language == attribution.language)
                        , onClick (SetLanguage language)
                        ]
                        []
                    , text (toString language)
                    ]
                ]

        featureSetRadio set =
            li []
                [ label []
                    [ input
                        [ type_ "radio"
                        , checked (set == attribution.featureCombo)
                        , onClick (SetFeatureCombo set)
                        ]
                        []
                    , text (toString set)
                    ]
                ]

        genreRadio genre =
            li []
                [ label []
                    [ input
                        [ type_ "radio"
                        , checked (genre == attribution.genre)
                        , onClick (SetGenre genre)
                        ]
                        []
                    , text (Genre.genreToString genre)
                    ]
                ]
    in
        [ Grid.col [ Col.attrs [ class "text-left box" ] ]
            [ h2 [] [ text "Language" ]
            , span [] [ text (t "settings-language") ]
            , ul [] (List.map languageRadio attribution.languages)
            ]
        , Grid.col [ Col.attrs [ class "text-left box" ] ]
            [ h2 [] [ text "Genre" ]
            , span [] [ text (t "settings-genre") ]
            , ul [] (List.map genreRadio genres)
            ]
        , Grid.col [ Col.attrs [ class "text-left box" ] ]
            [ h2 [] [ text "Feature Set" ]
            , span [] [ text (t "settings-feature-set") ]
            , ul [] (List.map featureSetRadio attribution.featureCombos)
            ]
        ]
