module Route exposing (..)

import Url.Parser exposing (Parser, (</>), int, map, oneOf, s, string, top, parse)
import Url exposing (Url)

type Route = Home | NewDraw | NotFoundRoute

routeParser : Parser (Route -> a) a
routeParser =
  oneOf
    [ map Home top
    , map NewDraw (s "new")
    ]

parseUrl : Url -> Route
parseUrl url =
    case parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

toString : Route -> String
toString route =
    case route of
        Home -> "Home"
        NewDraw -> "NewDraw"
        NotFoundRoute -> "NotFound"