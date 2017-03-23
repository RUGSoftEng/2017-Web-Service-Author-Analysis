port module Ports exposing (..)

{-| This module defines ports, elm's way of communicating with javascript.

Sending to javacscript creates a `Cmd msg`, and can be used from an `update` function.

Data from javascript is represented as a `Sub msg` - a subscription - that can be subscribed to
in `main`. The messages then find their way to the update function where the data from js can be handled.

also see the accompanying js in index.html
-}

import Types exposing (File)


{-| port for sending out (is this needed)?
-}
port readFiles : ( String, String ) -> Cmd msg


{-| port for listening for new files from javascript
-}
port addFile : (( String, File ) -> msg) -> Sub msg
