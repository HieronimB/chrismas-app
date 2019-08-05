module Create.View exposing (root)

import Autocomplete.Menu
import Create.Types exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
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
        [ height <| px 100
        , width fill
        , Background.color <| rgb255 92 99 118
        , Font.color <| rgb255 255 255 255
        ]
        [ text "Create new draw" ]


mainPanel : Model -> Element Msg
mainPanel model =
    row
        [ height <| fill
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
        , newExcludedInput model
        , createDrawBtn
        ]


viewPanel : Model -> Element Msg
viewPanel model =
    column
        [ height <| fillPortion 1
        , width fill
        ]
        [ row [ width fill ] [ participantsList model, excludedList model ] ]


participantsList : Model -> Element Msg
participantsList model =
    Element.table [ height fill ]
        { data = model.draw.participants
        , columns =
            [ { header = Element.text "Participants"
              , width = fill
              , view =
                    \p ->
                        row []
                            [ Element.text p
                            , Input.button
                                [ Background.color blue
                                , Font.color white
                                , Border.color darkBlue
                                , paddingXY 32 16
                                , Border.rounded 3
                                ]
                                { label = text "Remove"
                                , onPress = Just <| ForSelf (RemoveParticipant p)
                                }
                            ]
              }
            ]
        }


excludedList : Model -> Element Msg
excludedList model =
    Element.table [ height fill ]
        { data = model.draw.excluded
        , columns =
            [ { header = Element.text "Excluded"
              , width = fill
              , view =
                    \e ->
                        row []
                            [ Element.text (makeExcluded e)
                            , Input.button
                                [ Background.color blue
                                , Font.color white
                                , Border.color darkBlue
                                , paddingXY 32 16
                                , Border.rounded 3
                                ]
                                { label = text "Remove"
                                , onPress = Just <| ForSelf (RemoveExcluded e)
                                }
                            ]
              }
            ]
        }


makeExcluded : List String -> String
makeExcluded excluded =
    case excluded of
        p :: e :: xs ->
            p ++ " " ++ e

        _ ->
            "Error"


newDrawName : Model -> Element Msg
newDrawName model =
    el [ height <| px 100 ] <|
        Input.text []
            { text = model.draw.name
            , onChange = \name -> ForSelf (UpdateDrawName name)
            , placeholder = Nothing
            , label = Input.labelAbove [ Font.size 14, paddingXY 0 5 ] (text "Draw Name")
            }


newParticipantInput : Model -> Element Msg
newParticipantInput model =
    column [ height <| px 150 ]
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


newExcludedInput : Model -> Element Msg
newExcludedInput model =
    row [ height <| px 500 ]
        [ el [ alignTop ] <| Element.html <| Html.map (\a -> ForSelf (ParticipantAutoCompleteMsg a)) (Autocomplete.Menu.view model.participantAutocomplete)
        , el [ alignTop ] <| Element.html <| Html.map (\a -> ForSelf (ExcludedAutoCompleteMsg a)) (Autocomplete.Menu.view model.excludedAutocomplete)
        , Input.button
            [ Background.color blue
            , Font.color white
            , Border.color darkBlue
            , paddingXY 32 16
            , Border.rounded 3
            , width fill
            , alignTop
            ]
            { label = text "Add Excluded"
            , onPress = Just <| ForSelf AddExcluded
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
