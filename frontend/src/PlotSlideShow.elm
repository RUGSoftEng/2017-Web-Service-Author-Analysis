module PlotSlideShow exposing (State, Msg, Plot, Config, initialState, view, update, plot, config)

{-| An internal module that represents our plot slide show.
This module is built to be completely separated from our application code.

We hide constructors (exposing `State` instead of `State(..)` to provide encapsulation.

Heavily based on elm-sortable-table (https://github.com/evancz/elm-sortable-table/blob/master/src/Table.elm)
-}

import Html exposing (Html, text, h3, div)
import Html.Attributes exposing (class)
import Dict exposing (Dict)
import Pivot exposing (Pivot)
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import I18n exposing (Translator)


{-| Tracks the current plot

This module uses a Pivot (or ZipList) to represent a slideshow.

A pivot is essentially

type alias Pivot a = { left : List a, current : a , right : List a }

-}
type State
    = State (Pivot String)


initialState : String -> List String -> State
initialState x xs =
    State (Pivot.fromCons x xs)


{-| Describes a single plot
-}
type Plot data msg
    = Plot { id : String, render : data -> Html msg }


{-| Create the description of a plot, and how to render it
-}
plot :
    { id : String
    , render : data -> Html msg
    }
    -> Plot data msg
plot =
    Plot


{-| Describes a set of plots
-}
type Config data msg
    = Config
        { plots : Dict String (Plot data msg)
        , toMsg : Msg -> msg
        , t : Translator
        }


{-| Describe a set of plots, how to identify them and how
to convert plot messages to your app's message type
-}
config :
    { plots : Dict String (Plot data msg)
    , toMsg : Msg -> msg
    , t : Translator
    }
    -> Config data msg
config =
    Config


type Msg
    = Right
    | Left
    | MoveTo Int


{-| Move the focus of the slideshow
-}
update : Msg -> State -> State
update msg (State model) =
    -- commands don't make sense here, so we can omit them entirely
    case msg of
        Right ->
            Maybe.withDefault model (Pivot.goR model)
                |> State

        Left ->
            Maybe.withDefault model (Pivot.goL model)
                |> State

        MoveTo n ->
            Maybe.withDefault model (Pivot.goTo n model)
                |> State


{-| Convert your data to plots given a state and a config.
-}
view : Config data msg -> State -> data -> Html msg
view (Config ({ t } as config)) (State model) data =
    let
        active =
            Pivot.getC model

        menuItem index plotID =
            ButtonGroup.radioButton (plotID == active)
                [ Button.secondary, Button.onClick (MoveTo index) ]
                [ text (t (plotID ++ "-name")) ]

        menuItems =
            let
                plotIDs =
                    Pivot.getA model
            in
                -- only display buttons when there are 2+ plots
                if List.length plotIDs >= 2 then
                    List.indexedMap menuItem plotIDs
                else
                    []

        menu =
            Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                [ ButtonGroup.radioButtonGroup [] menuItems
                ]

        currentPlot =
            -- we could use dict to make this nicer, but not really worth the hassle
            case Dict.get active config.plots of
                Nothing ->
                    Grid.col [] []

                Just (Plot { id, render }) ->
                    Grid.col [ Col.attrs [ class "center-block text-center" ] ]
                        [ h3 [] [ text (t (id ++ "-title")) ]
                        , div [ class "text-left box" ] [ text (t (id ++ "-description")) ]
                        , render data
                        ]
    in
        Grid.container []
            [ Grid.row [] [ menu ]
                |> Html.map config.toMsg
            , Grid.row [] [ currentPlot ]
            ]
