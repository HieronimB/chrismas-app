module Create.Types exposing (..)

import Http

type InternalMsg = CreateDraw
                       | AddParticipant String
                       | UpdateParticipant String
                       | UpdateDrawName String

type ExternalMsg = DrawFinished (Result Http.Error String)

type Msg = ForSelf InternalMsg | ForParent ExternalMsg

type alias Model =
    { draw : NewDraw
    , participantName : String
    }

type alias NewDraw =
    { name : String
    , participants : List String
    , excluded : List (List String)
    }

type alias TranslationDictionary msg =
  { onCreateDrawMsg: InternalMsg -> msg
  , onDrawCreatedMsg: Result Http.Error String -> msg
  }

type alias Translator parentMsg = Msg -> parentMsg

translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onCreateDrawMsg, onDrawCreatedMsg } msg =
  case msg of
    ForSelf internal ->
      onCreateDrawMsg internal

    ForParent (DrawFinished result) ->
      onDrawCreatedMsg result