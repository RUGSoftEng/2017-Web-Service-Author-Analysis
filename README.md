# 2017-Web-Service-Author-Analysis

## Server-Client protocol 

*DRAFT* 

### Author Recognition 

**endpoint**: /api/attribution 

```elm
{-| Request to the server

Example JSON:
{ "knownAuthorText": "lorem", "unknownAuthorText": "ipsum" }

-}
type alias ToServer =
    { knownAuthorText : String, unknownAuthorText : String }


{-| Response from the server

Example JSON:
{ "sameAuthor": true, "confidence": 0.67 }

-}
type alias FromServer =
    { sameAuthor : Bool, confidence : Float }
```

