module Types exposing (..)

import Browser
import Browser.Navigation exposing (Key)
import Element
import Http
import Route exposing (Route)
import Url


type alias Model =
    {
     serverMessage : String
    , drawnFriend : String
    , key : Key
    , url : Url.Url
    , route : Route
    , draw : NewDraw
    , participantName : String
    }


type alias NewDraw =
    { name : String
    , participants : List String
    , excluded : List (List String)
    }


type Msg
    = Draw
    | OnServerResponse (Result Http.Error Friend)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | CreateDraw
    | AddParticipant String
    | UpdateParticipant String
    | UpdateDrawName String
    | OnDrawCreated (Result Http.Error Int)


type alias Friend =
    { firstname : String, lastname : String }