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
, "language": "EN" }

-}
type alias ToServerProfiling =
    { text : String
    , language : String }


{-| Response from server

Example JSON:
{ "Age groups": { "18-24": 0.2
                , "25-34": 0.2
                , "35-49": 0.2
                , "50-64": 0.2
                , "65-xx": 0.2
                }
, "Genders": { "Male": 0.4
             , "Female": 0.6
             }
}

-}
type alias FromServerProfiling =
    { "Age groups": { "18-24": number
                    , "25-34": number
                    , "35-49": number
                    , "50-64": number
                    , "65-xx": number
                    }
    , "Genders": { "Male": number
                 , "Female": number
                 }
    }
```
