module State exposing (capitalize, createDrawUrl, decodeFirstname, decodeLastname, drawUrl, encodeNewDraw, friendDecoder, init, update)

import Browser
import Browser.Navigation as Nav
import Http
import Json.Decode as Decode exposing (Decoder, field, map2, string)
import Json.Encode as Encode exposing (..)
import Route
import String exposing (dropLeft, left, toUpper)
import Types exposing (..)
import Url


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { serverMessage = ""
      , drawnFriend = ""
      , key = key
      , url = url
      , route = Route.parseUrl url
      , participantName = ""
      , drawId = ""
      , draw =
            { name = ""
            , participants = []
            , excluded = []
            }
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        OnServerResponse res ->
            case res of
                Ok r ->
                    ( { model | drawnFriend = capitalize r.firstname ++ " " ++ capitalize r.lastname, serverMessage = "" }, Cmd.none )

                Err err ->
                    ( { model | serverMessage = "Przepraszam, ale nie wiem kim jesteś " }, Cmd.none )

        Draw ->
            ( model, Http.get (drawUrl model) friendDecoder |> Http.send OnServerResponse )
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url, route = Route.parseUrl url }
            , Cmd.none
            )

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
            ( model, Http.post createDrawUrl (Http.jsonBody (encodeNewDraw model.draw)) Decode.string |> Http.send OnDrawCreated )

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

        OnDrawCreated result ->
            case result of
                            Ok r ->
                                ( { model | drawId = r }, (Nav.pushUrl model.key "draw-link"))

                            Err err ->
                                ( { model | serverMessage = "Error when creating new draw" }, Cmd.none )



drawUrl : Model -> String
drawUrl model =
    "/api/drawn"


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

encodeDrawn : String -> Int -> Value
encodeDrawn drawId participant =
    Encode.object
        [ ( "drawId", Encode.string drawId )
        , ( "participant", Encode.int participant )
        ]


decodeFirstname : Decoder String
decodeFirstname =
    field "firstname" Decode.string


decodeLastname : Decoder String
decodeLastname =
    field "lastname" Decode.string


friendDecoder : Decoder Friend
friendDecoder =
    map2 Friend decodeFirstname decodeLastname


capitalize : String -> String
capitalize str =
    (left 1 >> toUpper) str ++ dropLeft 1 str
