port module Main exposing (main, toJs)

import Browser
import State exposing (init, update)
import Types exposing (..)
import View

port toJs : String -> Cmd msg

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Losowanie"
                , body = [ View.root m ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
