module Types exposing (..)

import Autocomplete.Menu
import Browser
import Browser.Navigation exposing (Key)
import Create.Types
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
    , create : Create.Types.Model
    , autocomplete: Autocomplete.Menu.Model
    , currentFocus : Focused
    , drawId : String
    }

type Msg
    = Draw
    | OnServerResponse (Result Http.Error Friend)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | CreateDrawMsg Create.Types.InternalMsg
    | AutoCompleteMsg Autocomplete.Menu.Msg
    | UpdateServerMessage String
    | OnDrawCreated (Result Http.Error String)

type Focused
    = Simple
    | None

type alias Friend =
    { firstname : String, lastname : String }

translationDictionary
  = { onCreateDrawMsg = CreateDrawMsg
    , onDrawCreatedMsg = OnDrawCreated
    }

createTranslator = Create.Types.translator translationDictionary