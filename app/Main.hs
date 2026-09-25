-- | The whole app: a greeting and a tap counter.
--
-- hatter calls 'main' once when the Android activity (or iOS view)
-- starts. It returns the 'AppContext' the platform layer keeps around;
-- every render cycle the platform asks 'maView' for a fresh widget
-- tree and draws it with native views.
module Main where

import Data.IORef (IORef, modifyIORef', newIORef, readIORef)
import Data.Text qualified as Text
import Foreign.Ptr (Ptr)
import Hatter
  ( Action
  , MobileApp (..)
  , createAction
  , loggingMobileContext
  , newActionState
  , runActionM
  , startMobileApp
  )
import Hatter.AppContext (AppContext)
import Hatter.Widget (Widget, button, column, text)

main :: IO (Ptr AppContext)
main = do
  actionState <- newActionState
  tapCount <- newIORef (0 :: Int)
  -- Actions are handles the platform can call back into; the
  -- framework re-renders after each one fires.
  onTap <- runActionM actionState $ createAction (modifyIORef' tapCount (+ 1))
  startMobileApp
    MobileApp
      { maContext = loggingMobileContext
      , maView = \_userState -> helloView tapCount onTap
      , maActionState = actionState
      }

-- | Greeting plus a button that counts its own taps.
helloView :: IORef Int -> Action -> IO Widget
helloView tapCount onTap = do
  taps <- readIORef tapCount
  pure $
    column
      [ text "Hello from Haskell!"
      , text ("Button tapped " <> Text.pack (show taps) <> " times")
      , button "Tap me" onTap
      ]
