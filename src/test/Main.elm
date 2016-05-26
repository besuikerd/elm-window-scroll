module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Window.Scroll as Scroll

main : Program Never
main = App.program
  { init = init
  , subscriptions = subscriptions
  , update = update
  , view = view
  }

type Msg
  = NoOp
  | OnScroll Scroll.Offset

type alias Model =
  { offset: Scroll.Offset
  }

init : (Model, Cmd Msg)
init =
  ( Model
      (Scroll.Offset 0 0)
  , Cmd.none
  )

subscriptions : Model -> Sub Msg
subscriptions model =
  Scroll.scrolls OnScroll

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    OnScroll offset ->
      ({ model | offset = offset }, Cmd.none)

view : Model -> Html Msg
view model = div
  [ style
      [ ("height", "5000px")
      , ("width", "5000px")
      ]
  ]
  [ div
      [ style
          [ ("marginTop", toString model.offset.y ++ "px")
          , ("marginLeft", toString model.offset.x ++ "px")
          ]
      ]
      [ text <| scrollOffsetToString model.offset ]
  ]

scrollOffsetToString : Scroll.Offset -> String
scrollOffsetToString {x,y} = "(" ++ toString x ++ ", " ++ toString y ++ ")"
