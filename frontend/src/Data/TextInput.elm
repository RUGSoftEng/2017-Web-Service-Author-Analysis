module Data.TextInput
    exposing
        ( TextInput
        , empty
        , isEmpty
        , fromString
        , encoder
        , firstFileEncoder
        , toUpload
        , toPaste
        , setText
        , addFile
        , removeAtIndex
        , isPaste
        , text
        , files
        )

{-| Data structure for storing our text input.
There are two options: the user can paste or upload (one or more) files. Internally
, the paste case is represented as a file without a name
-}

import Data.File as File exposing (File)
import Json.Encode as Encode


type alias Fields =
    { text : String, files : List ( String, File ) }


type TextInput
    = Paste Fields
    | Upload Fields


getFields : TextInput -> Fields
getFields input =
    case input of
        Paste fields ->
            fields

        Upload fields ->
            fields


files =
    .files << getFields


text =
    .text << getFields


toUpload =
    Upload << getFields


toPaste =
    Paste << getFields


isPaste input =
    case input of
        Paste _ ->
            True

        _ ->
            False


mapFields : (Fields -> Fields) -> TextInput -> TextInput
mapFields f input =
    case input of
        Paste fields ->
            Paste (f fields)

        Upload fields ->
            Upload (f fields)


mapUpload : (Fields -> Fields) -> TextInput -> TextInput
mapUpload f input =
    case input of
        Paste fields ->
            Paste fields

        Upload fields ->
            Upload (f fields)


mapPaste : (Fields -> Fields) -> TextInput -> TextInput
mapPaste f input =
    case input of
        Paste fields ->
            Paste (f fields)

        Upload fields ->
            Upload fields


empty : TextInput
empty =
    Paste { text = "", files = [] }


isEmpty : TextInput -> Bool
isEmpty input =
    case input of
        Paste { text } ->
            text == ""

        Upload { files } ->
            List.isEmpty files


fromString : String -> TextInput
fromString str =
    Paste { text = str, files = [] }


setText : String -> TextInput -> TextInput
setText newText =
    mapPaste (\fields -> { fields | text = newText })


addFile : File -> TextInput -> TextInput
addFile file =
    mapUpload (\fields -> { fields | files = ( file.name, file ) :: fields.files })


removeAtIndex : Int -> TextInput -> TextInput
removeAtIndex n =
    mapUpload (\fields -> { fields | files = removeAtIndex_ n fields.files })


removeAtIndex_ : Int -> List a -> List a
removeAtIndex_ n items =
    case items of
        [] ->
            []

        x :: xs ->
            if n == 0 then
                xs
            else
                x :: removeAtIndex_ (n - 1) xs


inputModeToFiles : TextInput -> List File
inputModeToFiles state =
    case state of
        Paste { text } ->
            [ { name = "", content = text } ]

        Upload { files } ->
            List.map Tuple.second files


encoder : TextInput -> Encode.Value
encoder input =
    input
        |> inputModeToFiles
        |> List.map (.content >> Encode.string)
        |> Encode.list


firstFileEncoder : TextInput -> Encode.Value
firstFileEncoder input =
    case input of
        Paste { text } ->
            Encode.string text

        Upload { files } ->
            case files of
                ( _, { content } ) :: _ ->
                    Encode.string content

                [] ->
                    Encode.null
