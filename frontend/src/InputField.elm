module InputField exposing (State, Msg, init, update, view, OutMsg(..), addFile, encodeState, File)

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
import Bootstrap.Button as Button
import Bootstrap.ListGroup as ListGroup
import Json.Decode as Decode
import Json.Encode as Encode
import Dict exposing (Dict)
import Octicons exposing (searchIcon, searchOptions, xIcon, xOptions)
import ViewHelpers


type alias File =
    { name : String, content : String }


type State
    = Paste { text : String, files : Dict String File }
    | Upload { text : String, files : Dict String File }


type Msg
    = NoOp
    | SetPaste
    | SetUpload
    | AddFile File
    | SendListenForFiles
    | RemoveFile String
    | ChangeText String


{-| Wrapper. This way we can expose this functionality
without exposing Msg constructors

exposing the constructors of a type is seen as an anti-pattern
-}
addFile : File -> Msg
addFile =
    AddFile


type OutMsg
    = ListenForFiles


inputModeToFiles : State -> List File
inputModeToFiles state =
    case state of
        Paste { text } ->
            [ { name = "", content = text } ]

        Upload { files } ->
            Dict.values files


encodeState : State -> Encode.Value
encodeState mode =
    mode
        |> inputModeToFiles
        |> List.map (.content >> Encode.string)
        |> Encode.list


init : State
init =
    Paste { text = "", files = Dict.empty }


update : Msg -> State -> ( State, Cmd Msg, Maybe OutMsg )
update msg model =
    case model of
        Paste { text, files } ->
            case msg of
                NoOp ->
                    ( model, Cmd.none, Nothing )

                AddFile _ ->
                    update NoOp model

                SendListenForFiles ->
                    update NoOp model

                RemoveFile _ ->
                    update NoOp model

                SetPaste ->
                    update NoOp model

                SetUpload ->
                    ( Upload { text = text, files = files }, Cmd.none, Nothing )

                ChangeText newText ->
                    ( Paste { text = newText, files = files }, Cmd.none, Nothing )

        Upload { text, files } ->
            case msg of
                NoOp ->
                    ( model, Cmd.none, Nothing )

                SetPaste ->
                    ( Paste { text = text, files = files }, Cmd.none, Nothing )

                SetUpload ->
                    update NoOp model

                AddFile file ->
                    ( Upload { text = text, files = Dict.insert file.name file files }, Cmd.none, Nothing )

                SendListenForFiles ->
                    ( model, Cmd.none, Just ListenForFiles )

                RemoveFile name ->
                    ( Upload { text = text, files = Dict.remove name files }, Cmd.none, Nothing )

                ChangeText _ ->
                    update NoOp model


type alias Config =
    { label : String
    , fileInputId : String
    , radioButtonName : String
    }


view : State -> Config -> List (Html Msg)
view model config =
    [ h2 [] [ text config.label ]
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
                [ uploadListView RemoveFile data.files
                , div [ class "form-group" ]
                    [ input
                        [ type_ "file"
                        , on "change" (Decode.succeed SendListenForFiles)
                        , id config.fileInputId
                        ]
                        []
                    ]
                ]
    ]


switchButtons : State -> String -> Html Msg
switchButtons model name =
    let
        pasteText =
            case model of
                Paste _ ->
                    True

                Upload _ ->
                    False
    in
        ViewHelpers.radioButtons name
            [ ( pasteText, SetPaste, [ text "Paste Text" ] )
            , ( not pasteText, SetUpload, [ text "Upload File" ] )
            ]


{-|
Dict String File

Dict.vlaues : Dict comparable value -> List value

List.map : (a -> b) -> List a -> List b

ListGroup.ul : List (Item Msg) -> Html Msg
-}
uploadListView : (String -> msg) -> Dict String File -> Html msg
uploadListView toMsg files =
    files
        |> Dict.values
        |> List.map (uploadFileView toMsg)
        |> ListGroup.ul


uploadFileView : (String -> msg) -> File -> ListGroup.Item msg
uploadFileView toMsg file =
    ListGroup.li
        [ ListGroup.attrs [ class "justify-content-between" ] ]
        [ text file.name
        , label [ onClick (toMsg file.name) ] [ xIcon xOptions ]
        ]
