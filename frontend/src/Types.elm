module Types exposing (..)

import Autocomplete.Menu
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
    , drawId : String
    , autocomplete: Autocomplete.Menu.Model
    , currentFocus : Focused
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
    | OnDrawCreated (Result Http.Error String)
    | AutoCompleteMsg Autocomplete.Menu.Msg

type Focused
    = Simple
    | None

type alias Friend =
    { firstname : String, lastname : String }