module Draw.Types exposing (..)

import Autocomplete.Menu
import Http
type alias Model =
    { participants : List String
    , participantName : String
    , drawnFriend: String
    , serverMessage: String
    , autocomplete: Autocomplete.Menu.Model
    , currentFocus : Focused
    }

type InternalMsg = Draw | OnServerResponse (Result Http.Error Friend) | AutoCompleteMsg Autocomplete.Menu.Msg

type ExternalMsg = GoToCreate

type Msg = ForSelf InternalMsg | ForParent ExternalMsg

type alias Friend =
    { firstname : String, lastname : String }

type Focused
    = Simple
    | None

type alias TranslationDictionary msg =
  { onDrawMsg: InternalMsg -> msg
  , onGoToCreatedMsg: msg
  }

type alias Translator parentMsg = Msg -> parentMsg

translator : TranslationDictionary parentMsg -> Translator parentMsg
translator { onDrawMsg, onGoToCreatedMsg } msg =
  case msg of
    ForSelf internal ->
      onDrawMsg internal

    ForParent external ->
      onGoToCreatedMsg

