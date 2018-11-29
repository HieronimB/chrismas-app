port module Main exposing (Model, Msg(..), add1, init, main, toJs, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode as Decode exposing (Decoder, field, map2, string)



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
    }


init : Int -> ( Model, Cmd Msg )
init flags =
    ( { counter = flags, serverMessage = "", firstname = "", lastname = "" }, Cmd.none )



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
                    ( { model | serverMessage = r.firstname ++ " " ++ r.lastname }, Cmd.none )

                Err err ->
                    ( { model | serverMessage = "Error: " ++ httpErrorToString err }, Cmd.none )

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
        [ header []
            [ -- img [ src "/images/logo.png" ] []
              span [ class "logo" ] []
            , h1 [] [ text "Elm 0.19 Webpack Starter, with hot-reloading" ]
            ]
        , p [] [ text "Click on the button below to increment the state." ]
        , div [ class "pure-g" ]
            [ div [ class "pure-u-1-3" ]
                [ button
                    [ class "pure-button pure-button-primary"
                    , onClick Inc
                    ]
                    [ text "+ 1" ]
                , text <| String.fromInt model.counter
                ]
            , div [ class "pure-u-1-3" ]
                [ button
                    [ class "pure-button pure-button-primary"
                    , onClick Draw
                    ]
                    [ text "Losuj przyjaciela" ]
                , input [ type_ "text", placeholder "Imie", value model.firstname, onInput Firstname ] []
                , input [ type_ "text", placeholder "Nazwisko", value model.lastname, onInput Lastname ] []
                ]
            , div [ class "pure-u-1-3" ]
                [ button
                    [ class "pure-button pure-button-primary"
                    , onClick TestServer
                    ]
                    [ text "ping dev server" ]
                , text model.serverMessage
                ]
            ]
        , p [] [ text "Then make a change to the source code and see how the state is retained after you recompile." ]
        , p []
            [ text "And now don't forget to add a star to the Github repo "
            , a [ href "https://github.com/simonh1000/elm-webpack-starter" ] [ text "elm-webpack-starter" ]
            ]
        ]



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
                { title = "Elm 0.19 starter"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }
