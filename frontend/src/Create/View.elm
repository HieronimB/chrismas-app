module Create.View exposing (root)

import Create.Types exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)


root : Model -> Html Msg
root model =
    layout [] <|
        column [ height fill, width fill ]
            [ headerPanel
            , mainPanel model
            ]


headerPanel : Element Msg
headerPanel =
    row
        [ height <| fillPortion 1
        , width fill
        , Background.color <| rgb255 92 99 118
        , Font.color <| rgb255 255 255 255
        ]
        [ text "Create new draw" ]


mainPanel : Model -> Element Msg
mainPanel model =
    row
        [ height <| fillPortion 6
        , width fill
        ]
        [ interactivePanel model
        , viewPanel model
        ]


interactivePanel : Model -> Element Msg
interactivePanel model =
    column
        [ height <| fillPortion 1
        , width fill
        ]
        [ newDrawName model
        , newParticipantInput model
        , createDrawBtn
        ]


viewPanel : Model -> Element Msg
viewPanel model =
    column
        [ height <| fillPortion 1
        , width fill
        ]
        (participantsList model)

participantsList : Model -> List (Element Msg)
participantsList model =
    List.map (\p -> el [ height <| fillPortion 1 ] (text p)) model.draw.participants


newDrawName : Model -> Element Msg
newDrawName model =
    el [ height <| fillPortion 1 ] <|
        Input.text []
            { text = model.draw.name
            , onChange = \name -> ForSelf (UpdateDrawName name)
            , placeholder = Nothing
            , label = Input.labelAbove [ Font.size 14, paddingXY 0 5 ] (text "Draw Name")
            }


newParticipantInput : Model -> Element Msg
newParticipantInput model =
    column [ height <| fillPortion 1 ]
        [ Input.text []
            { text = model.participantName
            , onChange = \name -> ForSelf (UpdateParticipant name)
            , placeholder = Nothing
            , label = Input.labelAbove [ Font.size 14, paddingXY 0 5 ] (text "Participant")
            }
        , Input.button
            [ Background.color blue
            , Font.color white
            , Border.color darkBlue
            , paddingXY 32 16
            , Border.rounded 3
            , width fill
            ]
            { label = text "Add Participant"
            , onPress = Just <| ForSelf (AddParticipant model.participantName)
            }
        ]


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
            { label = text "Finish"
            , onPress = Just <| ForSelf CreateDraw
            }


darkBlue =
    Element.rgb 0 0 0.9


white =
    Element.rgb 1 1 1


blue =
    Element.rgb 0 0 0.8
