module State exposing (init, subscriptions, update)

import Browser
import Browser.Navigation as Nav
import Create.State
import Draw.State
import Route exposing (Route(..))
import Types exposing (..)
import Url


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        initModel =
            { serverMessage = ""
            , key = key
            , url = url
            , route = Route.parseUrl url
            , create = Create.State.init
            , drawId = ""
            , draw = Draw.State.init
            }

        newRoute =
            Route.parseUrl url

        ( newModel, newCmd ) =
            onNewRoute newRoute initModel
    in
    ( newModel
    , newCmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map drawTranslator (Draw.State.subscriptions model.draw)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                newRoute =
                    Route.parseUrl url

                ( newModel, newCmd ) =
                    onNewRoute newRoute model
            in
            ( { newModel | url = url, route = newRoute }
            , newCmd
            )

        CreateDrawMsg internalMsg ->
            let
                ( updatedModel, cmd ) =
                    Create.State.update internalMsg model.create
            in
            ( { model | create = updatedModel }, Cmd.map createTranslator cmd )

        UpdateServerMessage serverMessage ->
            ( { model | serverMessage = serverMessage }, Cmd.none )

        OnDrawCreated result ->
            case result of
                Ok r ->
                    ( { model | drawId = r }, Nav.pushUrl model.key "draw-link" )

                Err err ->
                    ( { model | serverMessage = "Could not create draw" }, Cmd.none )

        DrawMsg internalMsg ->
            let
                ( updatedModel, cmd ) =
                    Draw.State.update internalMsg model.draw model.drawId
            in
            ( { model | draw = updatedModel }, Cmd.map drawTranslator cmd )

        GoToCreateView ->
            ( model, Cmd.none )


onNewRoute : Route -> Model -> ( Model, Cmd Msg )
onNewRoute route model =
    case route of
        Draw drawId ->
            ( { model | drawId = drawId }
            , Cmd.map drawTranslator (Draw.State.fetchParticipants drawId)
            )

        NewDraw ->
            ( model, Cmd.none )

        NotFoundRoute ->
            ( model, Cmd.none )

        DrawLink ->
            ( model, Cmd.none )
