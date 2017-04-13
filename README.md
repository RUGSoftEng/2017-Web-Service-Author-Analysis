# Author Analysis 

A system for analyzing texts 

## Overview 

This project consists of three subsystems 

* `frontend`: a web interface to the system, requiring input and displaying results. 
* `webserver`: web server that feeds user input to the backend system, and sends results to the frontend. 
* `backend`: a machine learning system that performs the work of analyzing texts and making predictions. 

## Installation  

See the respective READMEs for 

* [frontend](frontend/README.md)
* [webserver](backend/README.md)
* [backend](https://github.com/sixhobbits/rug-authorship-web#installation)

## Server-Client protocol 

### Author Recognition 

**endpoint**: /api/attribution 

```elm
{-| Request to the server
The genre and featureSet attributes are identifiers refering to a predefined
setting.

Example JSON:
{ "knownAuthorTexts": [ "lorem", "Hello World!" ]
, "unknownAuthorText": "ipsum"
, "language": "EN"
, "genre": 0
, "featureSet": 0
}

-}
type alias ToServerAttribution =
    { knownAuthorTexts : List String
    , unknownAuthorText : String
    , language : String
    , genre : number
    , featureSet : number
    }


{-| Response from the server

Example JSON:
{ "sameAuthorConfidence": 0.67 }

-}
type alias FromServerAttribution =
    { sameAuthorConfidence : Float }
```

### Author Profiling

**endpoint**: /api/profiling

```elm
{-| Request to the server
The genre and featureSet attributes are identifiers refering to a predefined
setting.

Example JSON:
{ "text": "lorem ipsum"
, "language": "EN"
, "genre": 0
, "featureSet": 0 }

-}
type alias ToServerProfiling =
    { text : String
    , language : String
    , genre : number
    , featureSet : number }


{-| Response from server

Example JSON:
{ "age": "20-30"
, "gender": "M" }

-}
type alias FromServerProfiling =
    { age: String, gender: String }
```

