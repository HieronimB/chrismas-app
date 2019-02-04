module Route exposing (Route(..), parseUrl, routeParser, toString)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


type Route
    = Home
    | Draw String
    | NewDraw
    | NotFoundRoute
    | DrawLink


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home top
        , map Draw (s "draw" </> string)
        , map NewDraw (s "new")
        , map DrawLink (s "draw-link")
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
        Home ->
            "Home"

        Draw id ->
            "Home"

        NewDraw ->
            "NewDraw"

        NotFoundRoute ->
            "NotFound"

        DrawLink -> "DrawLink"

