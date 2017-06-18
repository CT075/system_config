
import XMonad
import XMonad.Config.Gnome

import XMonad.Actions.CycleWS as CWS
import XMonad.Layout.Tabbed as Tab

import XMonad.Util.EZConfig as EZ

import Data.Map as M

main =
  xmonad $ gnomeConfig
  { terminal = "gnome-terminal"
  , workspaces = myWorkspaces
  , modMask = myModMask
  , layoutHook = myLayout
  }
  `EZ.additionalKeysP`
  bindings

-- mod4Mask is win-super key
myModMask = mod4Mask

myWorkspaces :: [String]
myWorkspaces =
  [ "Quanta"
  , "Exia"
  , "Kyrios"
  , "Cherudim"
  , "Seraphim"
  , "Zabanya"
  , "Arios"
  , "Harute"
  , "Astraea"
  ]

myLayout = Tab.simpleTabbed

bindings :: [(String, X ())]
bindings =
  [ ("C-M-<right>", CWS.nextWS)
  , ("C-M-<left>", CWS.prevWS)
  ]

