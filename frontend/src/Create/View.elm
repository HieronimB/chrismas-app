module Create.View exposing (root)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Types exposing (..)


root : Model -> Html Msg
root model =
    layout [] <|
        column [ height fill, width fill ]
            [ channelPanel
            , el [ height <| fillPortion 1 ] (text model.participantName)
            , el [ height <| fillPortion 1 ] (text (List.foldl addWithSpace  "" model.draw.participants))
            , el [ height <| fillPortion 1 ] (text <| List.foldl addWithSpace "" (List.foldl (++) [] model.draw.excluded))
            , newDrawName model
            , newParticipantInput model
            , createDrawBtn
            ]

addWithSpace: String -> String -> String
addWithSpace first second = first ++ ", " ++ second

foldArray: List String -> List String -> List String
foldArray first second =  ["[" ++ (List.foldl addWithSpace  "" first) ++ "] " ++ "[" ++ (List.foldl addWithSpace  "" second) ++ "] "]

channelPanel : Element Msg
channelPanel =
    column
        [ height <| fillPortion 1
        , width fill
        , Background.color <| rgb255 92 99 118
        , Font.color <| rgb255 255 255 255
        ]
        [ text "New Draw" ]


newParticipantInput : Model -> Element Msg
newParticipantInput model =
    row [ height <| fillPortion 1 ]
        [ Input.button
            [ Background.color blue
            , Font.color white
            , Border.color darkBlue
            , paddingXY 32 16
            , Border.rounded 3
            , width fill
            ]
            { label = text "Add Participant"
            , onPress = Just <| AddParticipant model.participantName
            }
        , Input.text []
            { text = model.participantName
            , onChange = \name -> UpdateParticipant name
            , placeholder = Nothing
            , label = Input.labelAbove [ Font.size 14, paddingXY 0 5 ] (text "Participant")
            }
        ]


newDrawName : Model -> Element Msg
newDrawName model =
    el [ height <| fillPortion 1 ] <|
        Input.text []
            { text = model.draw.name
            , onChange = \name -> UpdateDrawName name
            , placeholder = Nothing
            , label = Input.labelAbove [ Font.size 14, paddingXY 0 5 ] (text "Draw Name")
            }


createDrawBtn : Element Msg
createDrawBtn =
    el [ height <| fillPortion 1 ] <|
        Input.button
            [ Background.color blue
            , Font.color white
            , Border.color darkBlue
            , paddingXY 32 16
            , Border.rounded 3
            , width fill
            ]
            { label = text "Create"
            , onPress = Just <| CreateDraw
            }


darkBlue =
    Element.rgb 0 0 0.9


white =
    Element.rgb 1 1 1


blue =
    Element.rgb 0 0 0.8
