port module Main exposing (Model, Msg(..), add1, init, main, toJs, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder, field, map2, string)
import String exposing (left, dropLeft, toUpper)



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
    }


init : Int -> ( Model, Cmd Msg )
init flags =
    ( { counter = 5, serverMessage = "", firstname = "", lastname = "", drawnFriend = "" }, Cmd.none )



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
        , p []
            []
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


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Losowanie prezentów"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }
