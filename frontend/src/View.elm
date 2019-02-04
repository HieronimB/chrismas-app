module View exposing (root)

import Create.View exposing (root)
import Html exposing (Html, button, div, h1, header, input, p, span, text)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Route
import Types exposing (..)

root : Model -> Html Msg
root model =
    case model.route of
        Route.Home ->
            homeView model

        Route.NewDraw ->
            Create.View.root model

        Route.NotFoundRoute ->
            div [ class "container" ] [ p [] [ text (Route.toString model.route) ] ]

        Route.Draw string ->
            homeView model

        Route.DrawLink ->
            div [ class "container" ] [ p [] [ text ("DrawId: " ++ model.drawId) ] ]


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
        , p [] [ text (Route.toString model.route) ]
        ]


drawnView : Model -> Html Msg
drawnView model =
    div [ class "pure-u-1-3" ]
        [ input [ type_ "text", placeholder "Imie" ] []
        , input [ type_ "text", placeholder "Nazwisko" ] []
        , div [ class "button-div" ]
            [ button
                [ class "pure-button pure-button-primary btn-draw"
                , onClick Draw
                ]
                [ text "Losuj" ]
            ]
        ]


afterDrawnView : Model -> Html Msg
afterDrawnView model =
    div [ class "pure-u-1-3" ]
        [ p [ class "drawn-friend" ] [ text ("Gratujace wylosowałeś: " ++ model.drawnFriend) ] ]


