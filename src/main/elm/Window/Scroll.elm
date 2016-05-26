effect module Window.Scroll where { subscription = MySub } exposing
  ( Offset
  , offset
  , offsetX
  , offsetY
  , scrolls
  )

{-| similar to [elm-lang/window](http://package.elm-lang.org/packages/elm-lang/window),
but for scroll events on the global window.

@docs Offset, offset, offsetX, offsetY, scrolls

-}


import Dom.LowLevel as Dom
import Json.Decode as Json exposing ((:=))
import Task exposing(Task)
import Process
import Native.Window.Scroll


{-| Scroll offset from the top left in pixels
-}
type alias Offset =
  { x: Int
  , y: Int
  }


{-| Get the current scroll offset
-}
offset : Task Never Offset
offset = Native.Window.Scroll.offset


{-| Get the horizontal scroll offset
-}
offsetX: Task Never Int
offsetX = Task.map .x offset


{-| Get the vertical scroll offset

-}
offsetY: Task Never Int
offsetY = Task.map .y offset


{-| Subscribe to global scroll events
-}
scrolls : (Offset -> msg) -> Sub msg
scrolls tagger = subscription (MySub tagger)


type MySub msg
  = MySub (Offset -> msg)

subMap : (a -> b) -> MySub a -> MySub b
subMap f (MySub tagger) = MySub (f << tagger)

type alias State msg =
  Maybe
    { subs: List (MySub msg)
    , pid: Process.Id
    }


init : Task Never (State msg)
init = Task.succeed Nothing


onEffects : Platform.Router msg Offset -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs oldState =
  case (oldState, newSubs) of
    (Nothing, []) ->
      Task.succeed Nothing

    (Just {pid}, []) ->
      Process.kill pid
        &> Task.succeed Nothing

    (Nothing, _) ->
      Process.spawn (Dom.onWindow "scroll" (Json.succeed ()) (\_ -> offset `Task.andThen` Platform.sendToSelf router))
        `Task.andThen` \pid ->

      Task.succeed (Just { subs = newSubs, pid = pid })

    (Just {pid}, _) ->
      Task.succeed (Just { subs = newSubs, pid = pid })


onSelfMsg : Platform.Router msg Offset -> Offset -> State msg -> Task Never (State msg)
onSelfMsg router dimensions state =
  case state of
    Nothing ->
      Task.succeed state

    Just {subs} ->
      let
        send (MySub tagger) =
          Platform.sendToApp router (tagger dimensions)
      in
        Task.sequence (List.map send subs)
          &> Task.succeed state


(&>) : Task a b -> Task a c -> Task a c
(&>) t1 t2 = t1 `Task.andThen` \_ -> t2
