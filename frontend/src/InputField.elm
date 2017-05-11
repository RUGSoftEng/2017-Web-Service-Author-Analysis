module InputField exposing (Model, Msg, init, update, view, subscriptions, addFile, encodeModel, File, encodeFirstFile, UpdateConfig, ViewConfig)

{-| Module for the input fields, providing a textarea to paste text, or a file picker for uploading files

This module features the standard tripled (init, update, view), but the update function has a different return type.
instead of the normal 2-tuple, we return a 3-tuple. The third value of this tuples is a signal to the caller to perform
some action.

Currently, there is only one signal: ListenForFiles. The assumption is that
the caller will listen for files (using ports and javascript), and that any found files
will be added to the state of the InputField.

See also the `AddFile` case of update and the `ListenForFiles` case in `updateProfiling`, both in Update.elm.
-}

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Bootstrap.Accordion as Accordion
import Bootstrap.Card as Card
import Bootstrap.Button as Button
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.ListGroup as ListGroup
import Json.Decode as Decode
import Json.Encode as Encode
import Dict exposing (Dict)
import Octicons exposing (searchIcon, searchOptions, xIcon, xOptions)
import ViewHelpers


type alias File =
    { name : String, content : String }


type Model
    = Paste { text : String, files : List ( String, File ), accordionModel : Accordion.State }
    | Upload { text : String, files : List ( String, File ), accordionModel : Accordion.State }


type Msg
    = NoOp
    | SetPaste
    | SetUpload
    | AddFile File
    | SendListenForFiles
    | RemoveFile Int
    | ChangeText String
    | AccordionMsg Accordion.State


init : Model
init =
    Paste { text = "", files = [], accordionModel = Accordion.initialState }


addFile : File -> Model -> Model
addFile file model =
    case model of
        Paste _ ->
            model

        Upload state ->
            Upload { state | files = ( file.name, file ) :: state.files }


type alias UpdateConfig =
    { readFiles : Cmd Msg }


update : UpdateConfig -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case model of
        Paste ({ text, files } as state) ->
            case msg of
                NoOp ->
                    ( model, Cmd.none )

                AccordionMsg accordionModel ->
                    ( Paste { state | accordionModel = accordionModel }
                    , Cmd.none
                    )

                AddFile _ ->
                    update config NoOp model

                SendListenForFiles ->
                    update config NoOp model

                RemoveFile _ ->
                    update config NoOp model

                SetPaste ->
                    update config NoOp model

                SetUpload ->
                    ( Upload state
                    , Cmd.none
                    )

                ChangeText newText ->
                    ( Paste { state | text = newText }
                    , Cmd.none
                    )

        Upload ({ text, files } as state) ->
            case msg of
                NoOp ->
                    ( model, Cmd.none )

                AccordionMsg accordionModel ->
                    ( Upload { state | accordionModel = Debug.log "new accordion state" accordionModel }
                    , Cmd.none
                    )

                SetPaste ->
                    ( Paste state, Cmd.none )

                SetUpload ->
                    update config NoOp model

                AddFile file ->
                    ( addFile file model, Cmd.none )

                SendListenForFiles ->
                    ( model, config.readFiles )

                RemoveFile index ->
                    ( Upload { state | files = removeAtIndex index files }, Cmd.none )

                ChangeText _ ->
                    update config NoOp model


removeAtIndex : Int -> List a -> List a
removeAtIndex n items =
    case items of
        [] ->
            []

        x :: xs ->
            if n == 0 then
                xs
            else
                x :: removeAtIndex (n - 1) xs


type alias ViewConfig =
    { label : String
    , fileInputId : String
    , radioButtonName : String
    , info : String
    , multiple : Bool
    }


view : ViewConfig -> Model -> List (Html Msg)
view config model =
    [ h2 [] [ text config.label ]
    , span [] [ text config.info ]
    , switchButtons model config.radioButtonName
    , case model of
        Paste data ->
            textarea
                [ onInput ChangeText
                , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                ]
                [ text data.text ]

        Upload data ->
            div []
                [ uploadListView data.accordionModel RemoveFile data.files
                , div [ class "form-group", class "file-upload-button", class "card-header" ]
                    [ span [] [ text "Choose file" ]
                    , input
                        [ type_ "file"
                        , on "change" (Decode.succeed SendListenForFiles)
                        , id config.fileInputId
                        , multiple config.multiple
                        , disabled (not config.multiple && not (List.isEmpty data.files))
                        ]
                        []
                    ]
                ]
    ]


switchButtons : Model -> String -> Html Msg
switchButtons model name =
    let
        -- determines which button is active
        pasteText =
            case model of
                Paste _ ->
                    True

                Upload _ ->
                    False
    in
        ButtonGroup.radioButtonGroup []
            [ ButtonGroup.radioButton
                pasteText
                [ Button.primary, Button.onClick SetPaste ]
                [ text "Paste Text" ]
            , ButtonGroup.radioButton
                (not pasteText)
                [ Button.primary, Button.onClick SetUpload ]
                [ text "Upload File" ]
            ]


uploadListView : Accordion.State -> (Int -> Msg) -> List ( String, File ) -> Html Msg
uploadListView accordionModel toMsg files =
    let
        card index file =
            Accordion.card
                { id = "file-upload-" ++ file.name
                , options = [ Card.attrs [ class "file-upload-card" ] ]
                , header =
                    (Accordion.header [] <| Accordion.toggle [] [ text file.name ])
                        |> Accordion.appendHeader [ label [ onClick (toMsg index) ] [ xOptions |> Octicons.size "30" |> xIcon ] ]
                , blocks =
                    [ Accordion.block []
                        [ Card.text [] [ text file.content ] ]
                    ]
                }

        cards =
            List.indexedMap (\index ( _, file ) -> card index file) files
    in
        Accordion.config AccordionMsg
            |> Accordion.withAnimation
            |> Accordion.cards cards
            |> Accordion.view accordionModel


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        state =
            case model of
                Paste data ->
                    data

                Upload data ->
                    data
    in
        Accordion.subscriptions state.accordionModel AccordionMsg


inputModeToFiles : Model -> List File
inputModeToFiles state =
    case state of
        Paste { text } ->
            [ { name = "", content = text } ]

        Upload { files } ->
            List.map Tuple.second files


encodeModel : Model -> Encode.Value
encodeModel mode =
    mode
        |> inputModeToFiles
        |> List.map (.content >> Encode.string)
        |> Encode.list


encodeFirstFile : Model -> Encode.Value
encodeFirstFile state =
    case state of
        Paste { text } ->
            Encode.string text

        Upload { files } ->
            case files of
                ( _, { content } ) :: _ ->
                    Encode.string content

                [] ->
                    -- TODO make this fail graciously
                    Debug.crash "no file to encode"
