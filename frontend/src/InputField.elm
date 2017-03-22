module InputField exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class, defaultValue, classList, attribute, name, type_, href, src, id, multiple, disabled, placeholder)
import Html.Events exposing (onClick, onInput, on, onWithOptions, defaultOptions)
import Bootstrap.Navbar as Navbar
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.ListGroup as ListGroup
import Json.Decode as Decode
import Dict exposing (Dict)
import Octicons exposing (searchIcon, searchOptions, xIcon, xOptions)


{-| Module for the input fields, providing a textarea to paste text, or a file picker for uploading files
-}
type ID
    = ID String


type alias File =
    { name : String, content : String }


type State
    = Paste { text : String, files : Dict String File }
    | Upload { text : String, files : Dict String File }


type Msg
    = NoOp
    | SetPaste
    | SetUpload
    | AddFile (File)
    | ListenForFiles_
    | RemoveFile String
    | ChangeText String


type OutMsg
    = ListenForFiles


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

                ListenForFiles_ ->
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

                ListenForFiles_ ->
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
                        , on "change" (Decode.succeed ListenForFiles_)
                        , id config.fileInputId {- , style [ ( "visibility", "hidden" ), ( "position", "absolute" ) ] -}
                        ]
                        []
                    , div [ class "input-group col-xs-12" ]
                        [ span [ class "input-group-btn" ]
                            [ Button.button
                                [ Button.primary
                                , Button.attrs [ class "input-lg" ]
                                ]
                                [ searchIcon (searchOptions |> Octicons.color "#FFF"), text "Browse" ]
                            ]
                        ]
                    ]
                ]
    ]



{-
   label [ class "btn btn-default btn-file" ]
       [ text "Browse"
       , input
           [ type_ "file"
           , id "fileInputField"
           , multiple True
           , style [ ( "display", "none" ) ]
           , on "change" (Decode.succeed (LoadFile KnownAuthor))
           ]
           [ text "Browse" ]
       ]
-}


switchButtons model name =
    let
        pasteText =
            case model of
                Paste _ ->
                    True

                Upload _ ->
                    False
    in
        radioButtons name
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


{-| we have to do this html manually, until my fix to the elm-bootstrap package gets merged
(this should be early next week, I spoke with the package author).

Until then, just assume this function works

this doesn't go into a separate file because why would it? just adds overhead.
-}
radioButtons : String -> List ( Bool, msg, List (Html msg) ) -> Html msg
radioButtons groupName options =
    let
        viewRadioButton ( checked, onclick, children ) =
            label
                [ classList [ ( "btn", True ), ( "btn-primary", True ), ( "active", checked ) ]
                , onWithOptions "click" { defaultOptions | preventDefault = True } (Decode.succeed onclick)
                ]
                (input [ attribute "autocomplete" "off", attribute "checked" "", name groupName, type_ "radio" ] [] :: children)
    in
        div [ class "btn-group", attribute "data-toggle" "buttons" ] (List.map viewRadioButton options)
