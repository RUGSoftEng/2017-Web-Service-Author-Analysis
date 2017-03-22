# 2017-Web-Service-Author-Analysis

## Server-Client protocol 

*DRAFT* 

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
    { knownAuthorTexts : String[]
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

