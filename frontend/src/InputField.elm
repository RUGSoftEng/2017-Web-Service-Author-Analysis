module InputField exposing (State, Msg, init, update, view, OutMsg(..), addFile, encodeState, File, encodeFirstFile)

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
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.ListGroup as ListGroup
import Json.Decode as Decode
import Json.Encode as Encode
import Dict exposing (Dict)
import Octicons exposing (searchIcon, searchOptions, xIcon, xOptions)
import ViewHelpers


type alias File =
    { name : String, content : String }


type State
    = Paste { text : String, files : List ( String, File ) }
    | Upload { text : String, files : List ( String, File ) }


type Msg
    = NoOp
    | SetPaste
    | SetUpload
    | AddFile File
    | SendListenForFiles
    | RemoveFile Int
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
            List.map Tuple.second files


encodeState : State -> Encode.Value
encodeState mode =
    mode
        |> inputModeToFiles
        |> List.map (.content >> Encode.string)
        |> Encode.list


encodeFirstFile : State -> Encode.Value
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


init : State
init =
    Paste { text = "", files = [] }


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
                    ( Upload { text = text, files = ( file.name, file ) :: files }, Cmd.none, Nothing )

                SendListenForFiles ->
                    ( model, Cmd.none, Just ListenForFiles )

                RemoveFile index ->
                    ( Upload { text = text, files = removeAtIndex index files }, Cmd.none, Nothing )

                ChangeText _ ->
                    update NoOp model


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


type alias Config =
    { label : String
    , fileInputId : String
    , radioButtonName : String
    , multiple : Bool
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
                        , multiple config.multiple
                        , disabled (not config.multiple && not (List.isEmpty data.files))
                        ]
                        []
                    ]
                ]
    ]


switchButtons : State -> String -> Html Msg
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


{-|
An example of type tetris: We have a `List (String, File)` and want `Html msg` through uploadFileView.

We first list possible subpaths

    files : List (String, File)
    toMsg : Int -> msg
    uploadFileView : msg -> File -> ListGroup.Item msg
    ListGroup.ul : List (ListGroup.Item msg) -> Html msg

    toMsg expects an index, and we have a list of files, so indexedMap may come in handy

    List.indexedMap : (\Int -> a -> b) -> List a -> List b


The first step we can take is to go from a tuple (String, File) to just File

    List.map : (a -> b) -> List a -> List b

    -- substituting `files : List (String, File)`

    List.map : ((String, File) -> b) -> List (String, File) -> List b

    -- substituting `Tuple.second : (a, b) -> b`

    List.map : ((String, File) -> File) -> List (String, File) -> List File

    -- thus

    List.map Tuple.second files

Here, we need a slightly more complicated function in the stead of `Tuple.second`, but the idea is the same

>   Note, see the similarity with modus ponens
>       A              Int
>       A => B         Int -> msg
>
>       B              msg
>
>   This is no accident, see also (https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence)

For correct display, the next step is reversing the list. Finally, we
can use ListGroup.ul to convert our `List (ListGroup.Item msg)` into `Html msg`
-}
uploadListView : (Int -> msg) -> List ( String, File ) -> Html msg
uploadListView toMsg files =
    files
        |> List.indexedMap (\index ( _, value ) -> uploadFileView (toMsg index) value)
        |> List.reverse
        |> ListGroup.ul


uploadFileView : msg -> File -> ListGroup.Item msg
uploadFileView toMsg file =
    ListGroup.li
        [ ListGroup.attrs [ class "justify-content-between" ] ]
        [ text file.name
        , label [ onClick toMsg ] [ xIcon xOptions ]
        ]
