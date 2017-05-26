module Request.Attribution exposing (get)

import Http
import Request.Helpers exposing (apiUrl)
import Data.Profiling.Input as ProfilingInput
import Data.Profiling.Prediction as ProfilingPrediction


get : ProfilingInput.Input -> Http.Request ProfilingPrediction.Prediction
get input =
    let
        body =
            Http.jsonBody (ProfilingInput.encoder input)
    in
        Http.post (apiUrl "/profiling") body ProfilingPrediction.decoder
