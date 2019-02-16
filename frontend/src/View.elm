module View exposing (root)

import Autocomplete.Menu
import Create.View exposing (root)
import Draw.View
import Html exposing (Html, button, div, h1, header, input, p, span, text)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
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
            Draw.View.root model

        Route.DrawLink ->
            Link.View.root model


