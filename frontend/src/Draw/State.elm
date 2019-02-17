module Draw.State exposing (..)

import Autocomplete.Menu
import Draw.Types exposing (Focused(..), Friend, InternalMsg(..), Model, Msg(..))
import Http
import Json.Decode exposing (Decoder, field, map2, string)
import String exposing (dropLeft, left, toUpper)

init : Model
init = {
       participants = []
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
        None -> Sub.none

update : InternalMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
    Draw ->
       ( model, Http.get { url = (drawUrl model), expect = Http.expectJson (\r -> ForSelf (OnServerResponse r)) friendDecoder }  )

    OnServerResponse res ->
            case res of
                    Ok r ->
                        ( { model | drawnFriend = capitalize r.firstname ++ " " ++ capitalize r.lastname, serverMessage = "" }, Cmd.none )

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
                            ({ updatedModel | currentFocus = Simple }, Cmd.none)

                        _ ->
                            (updatedModel, Cmd.none)


drawUrl : Model -> String
drawUrl model =
    "/api/drawn"

friendDecoder : Decoder Friend
friendDecoder =
    map2 Friend decodeFirstname decodeLastname

decodeFirstname : Decoder String
decodeFirstname =
    field "firstname" string


decodeLastname : Decoder String
decodeLastname =
    field "lastname" string

capitalize : String -> String
capitalize str =
    (left 1 >> toUpper) str ++ dropLeft 1 str