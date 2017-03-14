module Main exposing (main)

{-|
This file wires all parts of the app together.
-}

import Bootstrap.Navbar as Navbar
import Html
import View
import Update
import Types exposing (Model, Msg(NavbarMsg))


main : Program Never Model Msg
main =
    Html.program
        { update = Update.update
        , view = View.view
        , init = Update.initialState
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navbarState NavbarMsg



{- }
   routeParser : Parser (Route -> a) a
   routeParser =
       oneOf
           [ map Home top
           , map AuthorRecognition (s "author-recognition")
           , map AuthorProfiling (s "author-profiling")
           ]


   route = parsePath routeParser location
-}
