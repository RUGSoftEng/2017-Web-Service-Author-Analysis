module Request.Attribution exposing (get)

import Http
import Request.Helpers exposing (apiUrl)
import Data.Attribution.Input as AttributionInput
import Data.Attribution.Prediction as AttributionPrediction


get : AttributionInput.Input -> Http.Request AttributionPrediction.Prediction
get input =
    let
        body =
            Http.jsonBody (AttributionInput.encoder input)
    in
        Http.post (apiUrl "/attribution") body AttributionPrediction.decoder
