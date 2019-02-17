module Draw.State exposing (drawUrl, fetchParticipants, init, participantsDecoder, participantsUrl, subscriptions, update)

import Autocomplete.Menu exposing (Msg(..))
import Draw.Types exposing (DrawId, Focused(..), InternalMsg(..), Model, Msg(..))
import Http
import Json.Decode exposing (Decoder, field, list, map2, string)
import String exposing (dropLeft, left, toUpper)


init : Model
init =
    { participants = []
    , participantName = ""
    , drawnFriend = ""
    , serverMessage = ""
    , autocomplete = Autocomplete.Menu.init
    , currentFocus = None
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.currentFocus of
        Simple ->
            Sub.map (\a -> ForSelf (AutoCompleteMsg a)) (Autocomplete.Menu.subscriptions model.autocomplete)

        None ->
            Sub.none


update : InternalMsg -> Model -> DrawId -> ( Model, Cmd Msg )
update msg model drawId =
    case msg of
        Draw ->
            ( model, Http.get { url = drawUrl model drawId, expect = Http.expectJson (\r -> ForSelf (OnServerResponse r)) string } )

        OnServerResponse res ->
            case res of
                Ok r ->
                    ( { model | drawnFriend = r, serverMessage = "" }, Cmd.none )

                Err err ->
                    ( { model | serverMessage = "Przepraszam, ale nie wiem kim jesteś " }, Cmd.none )

        AutoCompleteMsg autoMsg ->
            let
                updatedModel =
                    { model
                        | autocomplete =
                            Tuple.first (Autocomplete.Menu.update autoMsg model.autocomplete)
                    }
            in
            case autoMsg of
                Autocomplete.Menu.OnFocus ->
                    ( { updatedModel | currentFocus = Simple }, Cmd.none )

                _ ->
                    ( updatedModel, Cmd.none )

        FetchParticipantsResponse result ->
            case result of
                Ok value ->
                    let
                        ( updatedModel, newCmd ) =
                            Autocomplete.Menu.update (SetPeople value) model.autocomplete
                    in
                    ( { model | serverMessage = "", autocomplete = updatedModel }, Cmd.map (\c -> ForSelf (AutoCompleteMsg c)) newCmd )

                Err error ->
                    ( { model | serverMessage = "Could not fetch participants" }, Cmd.none )


drawUrl : Model -> DrawId -> String
drawUrl model drawId =
    case model.autocomplete.selectedPerson of
        Just person ->
            "/api/drawn/" ++ drawId ++ "/" ++ person.name

        Nothing ->
            "/api/drawn/" ++ drawId


participantsUrl : DrawId -> String
participantsUrl drawId =
    "/api/participants/" ++ drawId


participantsDecoder : Decoder (List String)
participantsDecoder =
    list string


fetchParticipants : DrawId -> Cmd Msg
fetchParticipants drawId =
    Http.get
        { url = participantsUrl drawId
        , expect = Http.expectJson (\r -> ForSelf (FetchParticipantsResponse r)) participantsDecoder
        }
