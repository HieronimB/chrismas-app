module Link.View exposing (..)

import Autocomplete.Menu
import Route
import Types exposing (..)
import Html exposing (Html)
import Html exposing (Html, button, div, h1, header, input, p, span, text)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)

root : Model -> Html Msg
root model = div [ class "container" ] [ p [] [ text ("DrawId: " ++ model.drawId) ] ]