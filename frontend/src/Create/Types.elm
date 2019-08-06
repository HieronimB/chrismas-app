module Create.Types exposing (..)

import Autocomplete.Menu
import Http
import Set exposing (Set)

type InternalMsg = CreateDraw
                       | AddParticipant String
                       | UpdateParticipant String
                       | UpdateDrawName String
                       | AddExcluded
                       | RemoveParticipant String
                       | RemoveExcluded (List String)
                       | ParticipantAutoCompleteMsg Autocomplete.Menu.Msg
                       | ExcludedAutoCompleteMsg Autocomplete.Menu.Msg

type ExternalMsg = DrawFinished (Result Http.Error String)

type Msg = ForSelf InternalMsg | ForParent ExternalMsg

type alias Model =
    { draw : NewDraw
    , participant : NewParticipantInput
    , participantAutocomplete : Autocomplete.Menu.Model
    , excludedAutocomplete : Autocomplete.Menu.Model
    , currentFocus : Focused
    }

type Focused
    = Participant
    | Excluded
    | None


type alias NewDraw =
    { name : String
    , participants : Set String
    , excluded : Set (List String)
    }

type alias NewParticipantInput = {
        name: String,
        valid: Bool,
        message: String
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