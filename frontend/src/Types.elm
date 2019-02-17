module Types exposing (..)

import Browser
import Browser.Navigation exposing (Key)
import Create.Types
import Draw.Types
import Http
import Route exposing (Route)
import Url


type alias Model =
    {
     serverMessage : String
    , key : Key
    , url : Url.Url
    , route : Route
    , create : Create.Types.Model
    , drawId : String
    , draw : Draw.Types.Model
    }

type Msg
    = DrawMsg Draw.Types.InternalMsg
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | CreateDrawMsg Create.Types.InternalMsg
    | UpdateServerMessage String
    | OnDrawCreated (Result Http.Error String)
    | GoToCreateView

createTranslationDictionary
  = { onCreateDrawMsg = CreateDrawMsg
    , onDrawCreatedMsg = OnDrawCreated
    }

createTranslator = Create.Types.translator createTranslationDictionary

drawTranslationDictionary
  = { onDrawMsg = DrawMsg
    , onGoToCreatedMsg = GoToCreateView
    }

drawTranslator = Draw.Types.translator drawTranslationDictionary