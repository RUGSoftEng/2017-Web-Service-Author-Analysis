module InputField
    exposing
        ( Model
        , Msg
        , init
        , fromString
        , toStrings
        , update
        , view
        , subscriptions
        , addFile
        , isValid
        , UpdateConfig
        , ViewConfig
        )

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
import Json.Decode as Decode
import Data.File exposing (File)
import Data.TextInput as TextInput exposing (TextInput)
import Data.Validation as Validation exposing (Validation(..))
import Octicons exposing (searchIcon, searchOptions, xIcon, xOptions)


type Msg
    = NoOp
    | SetPaste
    | SetUpload
    | AddFile File
    | SendListenForFiles
    | RemoveFile Int
    | ChangeText String
    | AccordionMsg Accordion.State


type alias Model =
    { input : TextInput
    , validation : Validation
    , accordionModel : Accordion.State
    }


init : Model
init =
    { input = TextInput.empty
    , validation = NotLoaded
    , accordionModel = Accordion.initialState
    }


fromString : String -> Model
fromString string =
    { input = TextInput.fromString string, accordionModel = Accordion.initialState, validation = NotLoaded }


toStrings : Model -> List String
toStrings model =
    TextInput.toStrings model.input


addFile : File -> Model -> Model
addFile file model =
    { model | input = TextInput.addFile file model.input }


{-| Answers "can this input be sent to the server for prediction"
-}
isValid : Model -> Bool
isValid model =
    case model.validation of
        Error _ ->
            False

        NotLoaded ->
            False

        Success ->
            True

        Warning _ ->
            True


type alias UpdateConfig =
    { readFiles : Cmd Msg
    , validate : String -> Validation
    }


update : UpdateConfig -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    let
        revalidate model =
            { model | validation = config.validate (String.concat (TextInput.toStrings model.input)) }
    in
        case msg of
            NoOp ->
                ( model, Cmd.none )

            AccordionMsg accordionModel ->
                ( { model | accordionModel = accordionModel }
                , Cmd.none
                )

            AddFile file ->
                ( { model | input = TextInput.addFile file model.input }
                    |> revalidate
                , Cmd.none
                )

            RemoveFile index ->
                ( { model | input = TextInput.removeAtIndex index model.input }
                    |> revalidate
                , Cmd.none
                )

            ChangeText newText ->
                ( { model | input = TextInput.setText newText model.input }
                    |> revalidate
                , Cmd.none
                )

            SetPaste ->
                ( { model | input = TextInput.toPaste model.input }
                , Cmd.none
                )

            SetUpload ->
                ( { model | input = TextInput.toUpload model.input }
                , Cmd.none
                )

            SendListenForFiles ->
                ( model, config.readFiles )


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
    , if TextInput.isPaste model.input then
        case model.validation of
            NotLoaded ->
                div [ class "form-group" ]
                    [ textarea
                        [ onInput ChangeText
                        , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                        , class "form-control"
                        ]
                        [ text (TextInput.text model.input) ]
                    ]

            Success ->
                div [ class "form-group has-success" ]
                    [ textarea
                        [ onInput ChangeText
                        , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                        , class "form-control form-control-success"
                        ]
                        [ text (TextInput.text model.input) ]
                    ]

            Warning ws ->
                div [ class "form-group has-warning" ]
                    [ textarea
                        [ onInput ChangeText
                        , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                        , class "form-control form-control-warning"
                        ]
                        [ text (TextInput.text model.input) ]
                    , div [ class "form-control-feedback" ] [ text ws ]
                    ]

            Error es ->
                div [ class "form-group has-danger" ]
                    [ textarea
                        [ onInput ChangeText
                        , style [ ( "width", "100%" ), ( "height", "300px" ) ]
                        , class "form-control form-control-error"
                        ]
                        [ text (TextInput.text model.input) ]
                    , div [ class "form-control-feedback" ] [ text es ]
                    ]
      else
        div []
            [ uploadListView model.accordionModel RemoveFile (TextInput.files model.input)
            , label [ class "form-group", class "file-upload-button", class "card-header" ]
                [ span [] [ text "Choose file" ]
                , input
                    [ type_ "file"
                    , on "change" (Decode.succeed SendListenForFiles)
                    , id config.fileInputId
                    , multiple config.multiple
                    , disabled (not config.multiple && not (TextInput.isEmpty model.input))
                    ]
                    []
                ]
            ]
    ]


switchButtons : Model -> String -> Html Msg
switchButtons model name =
    ButtonGroup.radioButtonGroup []
        [ ButtonGroup.radioButton
            (TextInput.isPaste model.input)
            [ Button.primary, Button.onClick SetPaste ]
            [ text "Paste Text" ]
        , ButtonGroup.radioButton
            (not <| TextInput.isPaste model.input)
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
subscriptions { accordionModel } =
    Accordion.subscriptions accordionModel AccordionMsg
