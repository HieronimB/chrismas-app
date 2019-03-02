module Create.State exposing (createDrawUrl, encodeNewDraw, init, update)

import Create.Types exposing (..)
import Http
import Json.Encode as Encode exposing (..)


init : Model
init =
    { participantName = ""
    , excludedName = ""
    , participantExcludingName = ""
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

        CreateDraw ->
            ( model, Http.post { url = createDrawUrl, body = Http.jsonBody (encodeNewDraw model.draw), expect = Http.expectString (\r -> ForParent (DrawFinished r)) } )

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

        UpdateExcludedName newExcludedName ->
            ( { model | excludedName = newExcludedName }, Cmd.none )

        UpdateParticipantExcludingName newParticipantExcludingName ->
            ( { model | participantExcludingName = newParticipantExcludingName }, Cmd.none )

        AddExcluded newExcluded ->
            let
                oldDraw =
                    model.draw

                newNew =
                    { oldDraw | excluded = newExcluded :: oldDraw.excluded }
            in
            ( { model | draw = newNew, excludedName = "", participantExcludingName = "" }, Cmd.none )

        RemoveParticipant participantName ->
            let
                oldDraw = model.draw
                newParticipants = List.filter (\p -> p /= participantName) oldDraw.participants
                newExcluded = List.filter (\e -> not <| List.member participantName e) oldDraw.excluded
                newNew =
                    { oldDraw | participants = newParticipants, excluded = newExcluded }
            in
            ( { model | draw = newNew, participantName = "" }
            , Cmd.none
            )

        RemoveExcluded excludedToRemove ->
            let
               oldDraw = model.draw
               newExcluded = List.filter (\e -> not <| excludedToRemove == e) oldDraw.excluded
               newNew = { oldDraw | excluded = newExcluded }
            in
            ( { model | draw = newNew, participantName = "" }
            , Cmd.none
            )


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
