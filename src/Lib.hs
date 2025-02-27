{-# LANGUAGE OverloadedStrings #-}

module Lib where

import Options.Applicative
import System.Directory (doesDirectoryExist, removeDirectoryRecursive)
import Turtle

data Target = Target
  { qmkRepoLocation :: String,
    user :: String,
    keyboard :: String
  }

targetParser :: Parser Target
targetParser =
  Target
    <$> strOption
      ( long "qmkLoc"
          <> metavar "REPO"
          <> help "Target for the greeting"
      )
    <*> strOption
      ( long "user"
          <> value "yuanw"
          <> metavar "NAME"
          <> help "Target for the greeting"
      )
    <*> strOption
      ( long "keyboard"
          <> value "moonlander"
          <> short 'k'
          <> help "Whether to be quiet"
      )

run :: Target -> IO ()
run target = do
  -- should use testDir
  qmkE <- doesDirectoryExist (qmkRepoLocation target)
  if qmkE then putStrLn "found qmk directory" else error "cannot found qmk directory, abort!"
  deleteExistConfig target
  copyConfig target
  build

deleteExistConfig :: Target -> IO ()
deleteExistConfig target = do
  keyboardMapExist <- doesDirectoryExist (qmkRepoLocation target <> "/keyboards/" <> keyboard target <> "/keymaps/" <> user target)
  if keyboardMapExist then (putStrLn "found keyboard" >> removeDirectoryRecursive (qmkRepoLocation target <> "/keyboards/" <> keyboard target <> "/keymaps/" <> user target)) else putStrLn "not found keyboard"
  userKeyMapExist <- doesDirectoryExist (qmkRepoLocation target <> "/users/" <> user target)
  if userKeyMapExist then (putStrLn "found user keymap" >> removeDirectoryRecursive (qmkRepoLocation target <> "/users/" <> user target)) else putStrLn "not found user map"

copyConfig :: Target -> IO ()
copyConfig target = do
  cptree ("./keyboards" </> decodeString (keyboard target) </> "keymaps" </> decodeString (user target)) (decodeString (qmkRepoLocation target) </> "keyboards" </> decodeString (keyboard target) </> "keymaps" </> decodeString (user target))
  cptree ("./users" </> decodeString (user target)) (decodeString (qmkRepoLocation target) </> "users" </> decodeString (user target))

build :: IO ()
build = do
  cd "/home/yuanw/workspace/qmk_firmware"
  view $ inshellWithErr "alacritty -e util/docker_build.sh moonlander:yuanw" empty
