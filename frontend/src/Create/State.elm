module Create.State exposing (createDrawUrl, encodeNewDraw, init, subscriptions, update)

import Autocomplete.Menu as AutoComp
import Create.Types exposing (..)
import Http
import Json.Encode as Encode exposing (..)
import Set


init : Model
init =
    { participant =
        { name = ""
        , valid = True
        , message = ""
        }
    , participantAutocomplete = AutoComp.init
    , excludedAutocomplete = AutoComp.init
    , currentFocus = None
    , draw =
        { name = ""
        , participants = Set.empty
        , excluded = Set.empty
        }
    }


subscriptions : Model -> Sub Create.Types.Msg
subscriptions model =
    case model.currentFocus of
        Participant ->
            Sub.map (\a -> ForSelf (ParticipantAutoCompleteMsg a)) (AutoComp.subscriptions model.participantAutocomplete)

        Excluded ->
            Sub.map (\a -> ForSelf (ExcludedAutoCompleteMsg a)) (AutoComp.subscriptions model.excludedAutocomplete)

        None ->
            Sub.none


update : InternalMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddParticipant participant ->
            let
                oldDraw =
                    model.draw

                oldParticipant =
                    model.participant

                newParticipants =
                    Set.insert participant oldDraw.participants

                ( newParticipantUpdatedModel, participantNewCmd ) =
                    AutoComp.update (AutoComp.SetPeople <| Set.toList newParticipants) model.participantAutocomplete

                ( newExcludedUpdatedModel, excludedNewCmd ) =
                    AutoComp.update (AutoComp.SetPeople <| Set.toList newParticipants) model.excludedAutocomplete

                newDraw =
                    { oldDraw | participants = newParticipants, excluded = Set.insert [ participant, participant ] oldDraw.excluded }

                newParticipant =
                    { oldParticipant | name = "" }
            in
            ( { model | draw = newDraw, participant = newParticipant, participantAutocomplete = newParticipantUpdatedModel, excludedAutocomplete = newExcludedUpdatedModel }
            , Cmd.batch [ Cmd.map (\c -> ForSelf (ParticipantAutoCompleteMsg c)) participantNewCmd, Cmd.map (\c -> ForSelf (ExcludedAutoCompleteMsg c)) excludedNewCmd ]
            )

        CreateDraw ->
            ( model, Http.post { url = createDrawUrl, body = Http.jsonBody (encodeNewDraw model.draw), expect = Http.expectString (\r -> ForParent (DrawFinished r)) } )

        UpdateParticipant participant ->
            let
                oldParticipant =
                    model.participant

                newParticipant =
                    { oldParticipant | name = participant }
            in
            ( { model | participant = newParticipant }, Cmd.none )

        UpdateDrawName drawName ->
            let
                oldDraw =
                    model.draw

                newDraw =
                    { oldDraw | name = drawName }
            in
            ( { model | draw = newDraw }, Cmd.none )

        AddExcluded ->
            let
                oldDraw =
                    model.draw

                participantExcludingPerson =
                    Maybe.withDefault { name = "" } model.participantAutocomplete.selectedPerson

                excludedPerson =
                    Maybe.withDefault { name = "" } model.excludedAutocomplete.selectedPerson

                newNew =
                    { oldDraw | excluded = Set.insert [ participantExcludingPerson.name, excludedPerson.name ] oldDraw.excluded }
            in
            ( { model | draw = newNew }, Cmd.none )

        RemoveParticipant participantName ->
            let
                oldDraw =
                    model.draw

                newParticipants =
                    Set.filter (\p -> p /= participantName) oldDraw.participants

                newExcluded =
                    Set.filter (\e -> not <| List.member participantName e) oldDraw.excluded

                newNew =
                    { oldDraw | participants = newParticipants, excluded = newExcluded }
            in
            ( { model | draw = newNew }
            , Cmd.none
            )

        RemoveExcluded excludedToRemove ->
            let
                oldDraw =
                    model.draw

                newExcluded =
                    Set.filter (\e -> not <| excludedToRemove == e) oldDraw.excluded

                newNew =
                    { oldDraw | excluded = newExcluded }
            in
            ( { model | draw = newNew }
            , Cmd.none
            )

        ParticipantAutoCompleteMsg participantAutoMsg ->
            let
                updatedModel =
                    { model
                        | participantAutocomplete =
                            Tuple.first (AutoComp.update participantAutoMsg model.participantAutocomplete)
                    }
            in
            case participantAutoMsg of
                AutoComp.OnFocus ->
                    ( { updatedModel | currentFocus = Participant }, Cmd.none )

                _ ->
                    ( updatedModel, Cmd.none )

        ExcludedAutoCompleteMsg excludedAutoMsg ->
            let
                updatedModel =
                    { model
                        | excludedAutocomplete =
                            Tuple.first (AutoComp.update excludedAutoMsg model.excludedAutocomplete)
                    }
            in
            case excludedAutoMsg of
                AutoComp.OnFocus ->
                    ( { updatedModel | currentFocus = Excluded }, Cmd.none )

                _ ->
                    ( updatedModel, Cmd.none )


createDrawUrl : String
createDrawUrl =
    "/api/create"


encodeNewDraw : NewDraw -> Value
encodeNewDraw newDraw =
    Encode.object
        [ ( "name", Encode.string newDraw.name )
        , ( "participants", Encode.set Encode.string newDraw.participants )
        , ( "excluded", Encode.set (Encode.list Encode.string) newDraw.excluded )
        ]
