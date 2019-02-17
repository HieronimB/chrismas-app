module View exposing (root)

import Create.View exposing (root)
import Draw.View
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (class)
import Link.View
import Route
import Types exposing (..)

root : Model -> Html Msg
root model =
    case model.route of
        Route.NewDraw ->
            Html.map createTranslator (Create.View.root model.create)

        Route.NotFoundRoute ->
            div [ class "container" ] [ p [] [ text (Route.toString model.route) ] ]

        Route.Draw string ->
            Html.map drawTranslator (Draw.View.root model.draw)

        Route.DrawLink ->
            Link.View.root model


