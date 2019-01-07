module Create exposing (..)

import Html exposing (Html)
import Route
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input

darkBlue =
    Element.rgb 0 0 0.9
white =
    Element.rgb 1 1 1
blue =
    Element.rgb 0 0 0.8

createDrawView : msg -> (String -> msg) -> String -> Html msg
createDrawView addBtn updateInput name = layout [] <|
                                column [ height fill, width fill ]
                                    [ channelPanel
                                    , el [ height <| fillPortion 1 ] (text name)
                                    , nameInput addBtn updateInput name
                                    ]

channelPanel : Element msg
channelPanel =
    column
        [ height <| fillPortion 1
        , width fill
        , Background.color <| rgb255 92 99 118
        , Font.color <| rgb255 255 255 255
        ]
        [ text "New Draw" ]


nameInput: msg -> (String -> msg) -> String -> Element msg
nameInput addBtn updateInput name = row [] [
    Input.button [
        Background.color blue
        , Font.color white
        , Border.color darkBlue
        , paddingXY 32 16
        , Border.rounded 3
        , width fill
    ] {
        label = text "Dodaj"
        , onPress = Just addBtn
    }
    , Input.text [] { text = name
        , onChange = updateInput
        , placeholder = Nothing
        , label = Input.labelAbove [ Font.size 14, paddingXY 0 5 ] (text "Name")
    }]

