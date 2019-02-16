module Create.State exposing (..)

import Create.Types exposing (..)
import Http
import Json.Encode exposing (Value)
import Json.Encode as Encode exposing (..)


init : Model
init = {
       participantName = ""
      , draw =
            { name = ""
            , participants = []
            , excluded = []
            }
    }

update : InternalMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddParticipant participant ->
                let
                    oldDraw =
                        model.draw

                    newNew =
                        { oldDraw | participants = participant :: oldDraw.participants, excluded = [ participant, participant ] :: oldDraw.excluded }
                in
                ( { model | draw = newNew, participantName = "" }
                , Cmd.none
                )

        CreateDraw -> ( model, Http.post { url = createDrawUrl, body = (Http.jsonBody (encodeNewDraw model.draw)), expect = Http.expectString (\r -> ForParent (DrawFinished r)) } )

        UpdateParticipant participant ->
                        ( { model | participantName = participant }, Cmd.none )

        UpdateDrawName drawName ->
                        let
                            oldDraw =
                                model.draw

                            newDraw =
                                { oldDraw | name = drawName }
                        in
                        ( { model | draw = newDraw }, Cmd.none )

createDrawUrl : String
createDrawUrl =
    "/api/create"

encodeNewDraw : NewDraw -> Value
encodeNewDraw newDraw =
    Encode.object
        [ ( "name", Encode.string newDraw.name )
        , ( "participants", Encode.list Encode.string newDraw.participants )
        , ( "excluded", Encode.list (Encode.list Encode.string) newDraw.excluded )
        ]

