
import XMonad
import XMonad.Config.Gnome

import XMonad.Actions.CycleWS as CWS
import XMonad.Layout.Tabbed as Tab

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run
import XMonad.Util.EZConfig as EZ

import Data.Map as M

main = do
    xmproc <- spawnPipe "/run/current-system/sw/bin/xmobar ~/.xmonad/xmobar.hs"
    xmonad $ gnomeConfig
      { terminal = "gnome-terminal"
      , workspaces = myWorkspaces
      , modMask = myModMask
      , layoutHook = avoidStruts $ myLayout
      , manageHook = manageDocks <+> manageHook gnomeConfig
      , logHook = myLogHook xmproc
      } `EZ.additionalKeysP` bindings

xmobarTitleColor = "#42f48f"
xmobarCurrentWorkspaceColor = "#4298f4"

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

myLogHook pr = dynamicLogWithPP $ xmobarPP
               { ppOutput = hPutStrLn pr
               , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
               , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
               , ppSep = " "
               }

myLayout = Tab.simpleTabbed

bindings :: [(String, X ())]
bindings =
  [ ("C-M-<right>", CWS.nextWS)
  , ("C-M-<left>", CWS.prevWS)
  , ("C-M-S-<right>", CWS.shiftToNext >> CWS.nextWS)
  , ("C-M-S-<left>", CWS.shiftToPrev >> CWS.prevWS)
  , ("M-p", spawn "dmenu_run")
  ]

