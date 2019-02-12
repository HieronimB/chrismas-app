module Create.Types exposing (..)

import Http
type Msg = CreateDraw
            | AddParticipant String
            | UpdateParticipant String
            | UpdateDrawName String
            | OnDrawCreated (Result Http.Error String)