module Main exposing (main)

{-|
This file wires all parts of the app together.
-}

import Bootstrap.Navbar as Navbar
import View
import Update
import Types exposing (Model, Msg(NavbarMsg, UrlChange))
import Navigation


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { update = Update.update
        , view = View.view
        , init = Update.initialState
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navbarState NavbarMsg
