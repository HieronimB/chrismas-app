module Draw.View exposing (..)

import Autocomplete.Menu
import Draw.Types exposing (InternalMsg(..), Model, Msg(..))
import Html exposing (Html)
import Html exposing (Html, button, div, h1, header, p, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)

root : Model -> Html Msg
root model = homeView model

homeView : Model -> Html Msg
homeView model =
    div [ class "container" ]
        [ div [ id "snowflakeContainer" ] [ p [ class "snowflake" ] [ text "*" ] ]
        , header []
            [ -- img [ src "/images/logo.gif" ] []
              span [ class "logo" ] []
            , h1 [ class "title" ] [ text "Losowanie prezentów - Wigilia 2018" ]
            ]
        , p [ class "description" ] [ text "Wpisz swoje imie i nazwisko a następnie kiknij 'Losuj', aby wylosować osobę, którą uszczęśliwisz prezetem :)" ]
        , div [ class "pure-g" ]
            [ div [ class "pure-u-1-3" ]
                []
            , if String.isEmpty model.drawnFriend then
                drawnView model

              else
                afterDrawnView model
            , div [ class "pure-u-1-3" ]
                []
            ]
        , p [ class "server-message" ] [ text model.serverMessage ]
        ]

afterDrawnView : Model -> Html Msg
afterDrawnView model =
    div [ class "pure-u-1-3" ]
        [ p [ class "drawn-friend" ] [ text ("Gratujace wylosowałeś: " ++ model.drawnFriend) ] ]

drawnView : Model -> Html Msg
drawnView model =
    div [ class "pure-u-1-3" ]
        [ Html.map (\a -> ForSelf (AutoCompleteMsg a)) (Autocomplete.Menu.view model.autocomplete)
        , div [ class "button-div" ]
            [ button
                [ class "pure-button pure-button-primary btn-draw"
                , onClick (ForSelf Draw)
                ]
                [ text "Losuj" ]
            ]
        ]