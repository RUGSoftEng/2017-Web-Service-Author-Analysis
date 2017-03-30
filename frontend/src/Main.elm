module Main exposing (main)

{-|
This file wires all parts of the app together.
-}

import Bootstrap.Navbar as Navbar
import View
import Update
import Ports
import Types exposing (Model, Msg(NavbarMsg, UrlChange, AddFile))
import Navigation


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { update = Update.update
        , view = View.view
        , init = Update.initialState
        , subscriptions = subscriptions
        }


{-| Signals from the outside world that our app may want to respond to
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ -- fires when an item in the navbar is clicked
          -- this will change what item is highlighted
          Navbar.subscriptions model.navbarState NavbarMsg
        , Ports.addFile AddFile
        ]
