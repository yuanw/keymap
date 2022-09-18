module Main where

import Data.Semigroup ((<>))
import Lib
import Options.Applicative

main :: IO ()
main = greet =<< execParser opts
  where
    opts =
      info
        (targetParser <**> helper)
        ( fullDesc
            <> progDesc "Print a greeting for TARGET"
            <> header "hello - a test for optparse-applicative"
        )

greet :: Target -> IO ()
greet = run
