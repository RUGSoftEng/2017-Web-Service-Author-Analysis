module DisplayMode exposing (DisplayMode(..), map, update, value)


type DisplayMode a
    = Editor a
    | Results a
    | Loading a


map : (a -> b) -> DisplayMode a -> DisplayMode b
map f mode =
    case mode of
        Editor value ->
            Editor (f value)

        Results value ->
            Results (f value)

        Loading value ->
            Loading (f value)


update : (a -> ( b, Cmd msg )) -> DisplayMode a -> ( DisplayMode b, Cmd msg )
update updateValue mode =
    case map updateValue mode of
        Editor ( model, cmd ) ->
            ( Editor model, cmd )

        Results ( model, cmd ) ->
            ( Results model, cmd )

        Loading ( model, cmd ) ->
            ( Loading model, cmd )


value : DisplayMode a -> a
value mode =
    case mode of
        Editor value ->
            value

        Results value ->
            value

        Loading value ->
            value
