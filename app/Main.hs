module Main (main) where

import Data.Solitaire (fullDeck, shuffleM)

main :: IO ()
main = shuffleM fullDeck >>= print
