port module Main exposing (Model, Msg(..), add1, init, main, toJs, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder, field, map2, string)
import Route exposing (Route)
import Create exposing (createDrawView)
import String exposing (left, dropLeft, toUpper)
import Url


-- ---------------------------
-- PORTS
-- ---------------------------


port toJs : String -> Cmd msg



-- ---------------------------
-- MODEL
-- ---------------------------


type alias Model =
    { counter : Int
    , serverMessage : String
    , firstname: String
    , lastname: String
    , drawnFriend: String
    , key : Nav.Key
    , url : Url.Url
    , route : Route
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { counter = 5
        , serverMessage = ""
        , firstname = ""
        , lastname = ""
        , drawnFriend = ""
        , key = key
        , url = url
        , route = Route.parseUrl url
      }, Cmd.none )


-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Inc
    | Set Int
    | TestServer
    | Draw
    | Firstname String
    | Lastname String
    | OnServerResponse (Result Http.Error Friend)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | AddParticipant

type alias Friend = { firstname: String, lastname: String }

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Inc ->
            ( add1 model, toJs "Hello Js" )

        Set m ->
            ( { model | counter = m }, toJs "Hello Js" )

        TestServer ->
            ( model, Cmd.none)

        OnServerResponse res ->
            case res of
                Ok r ->
                    ( { model | drawnFriend = (capitalize r.firstname) ++ " " ++ (capitalize r.lastname), serverMessage = "" }, Cmd.none )

                Err err ->
                    ( { model | serverMessage = "Przepraszam, ale nie wiem kim jesteś " ++ (capitalize model.firstname) ++ " " ++ (capitalize model.lastname) ++ " :( Czy na pewno wpisałeś poprawne imie i nazwisko ?" }, Cmd.none )

        Draw ->
            (model, Http.get (drawUrl model) friendDecoder |> Http.send OnServerResponse)
        Firstname name ->
            ({ model | firstname = name}, Cmd.none)
        Lastname name ->
            ({ model | lastname = name }, Cmd.none)
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
        AddParticipant

drawUrl : Model -> String
drawUrl model = "/api/draw?firstname=" ++ model.firstname ++ "&lastname=" ++ model.lastname

decodeFirstname : Decoder String
decodeFirstname = field "firstname" string

decodeLastname : Decoder String
decodeLastname = field "lastname" string

friendDecoder : Decoder Friend
friendDecoder = map2 Friend decodeFirstname decodeLastname

httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        BadUrl _ ->
            "BadUrl"

        Timeout ->
            "Timeout"

        NetworkError ->
            "NetworkError"

        BadStatus _ ->
            "BadStatus"

        BadPayload _ _ ->
            "BadPayload"


{-| increments the counter

    add1 5 --> 6

-}
add1 : Model -> Model
add1 model =
    { model | counter = model.counter + 1 }



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view model =
    case model.route of
        Route.Home -> homeView model
        Route.NewDraw -> createDrawView AddParticipant (\name -> Firstname name) model.firstname
        Route.NotFoundRoute -> div [ class "container" ] [ p [] [ text (Route.toString model.route) ] ]



homeView : Model -> Html Msg
homeView model =
    div [ class "container" ]
            [ div [ id "snowflakeContainer" ] [ p [ class "snowflake" ] [text "*"] ],
            header []
                [ -- img [ src "/images/logo.gif" ] []
                  span [ class "logo" ] []
                , h1 [ class "title" ] [ text "Losowanie prezentów - Wigilia 2018" ]
                ]
            , p [ class "description" ] [ text "Wpisz swoje imie i nazwisko a następnie kiknij 'Losuj', aby wylosować osobę, którą uszczęśliwisz prezetem :)" ]
            , div [ class "pure-g" ]
                [ div [ class "pure-u-1-3" ]
                    []
                , if String.isEmpty model.drawnFriend
                    then drawnView model else afterDrawnView model
                , div [ class "pure-u-1-3" ]
                    []
                ]
            , p [ class "server-message" ] [ text model.serverMessage ]
            , p [] [ text (Route.toString model.route) ]
            ]

drawnView : Model -> Html Msg
drawnView model = div [ class "pure-u-1-3" ]
                            [   input [ type_ "text", placeholder "Imie", value model.firstname, onInput Firstname ] []
                                , input [ type_ "text", placeholder "Nazwisko", value model.lastname, onInput Lastname ] []
                                ,div [ class "button-div" ] [ button
                                            [ class "pure-button pure-button-primary btn-draw"
                                                , onClick Draw
                                            ]
                                            [ text "Losuj" ]
                                        ]
                            ]

afterDrawnView : Model -> Html Msg
afterDrawnView model = div [ class "pure-u-1-3" ]
                             [ p [ class "drawn-friend" ] [ text ("Gratujace wylosowałeś: " ++ model.drawnFriend) ] ]


capitalize : String -> String
capitalize str =
  (left 1 >> toUpper) str ++ dropLeft 1 str

-- ---------------------------
-- MAIN
-- ---------------------------


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Losowanie prezentów"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
