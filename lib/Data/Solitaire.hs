module Data.Solitaire
  ( fullDeck,
    riffleShuffle,
    shuffleM,
    module Data.Solitaire.Card,
  )
where

import Data.Solitaire.Card
import System.Random.Shuffle (shuffleM)

fullDeck :: [Card]
fullDeck =
  concatMap
    ( \suit ->
        [Card (Face face) suit | face <- [minBound .. maxBound]]
          <> [Card (Pips pips) suit | pips <- [2 .. 10]]
    )
    [minBound .. maxBound]

riffleShuffle :: Int -> [a] -> [a]
riffleShuffle n = (!! n) . iterate (uncurry riffle . cut)

cut :: [a] -> ([a], [a])
cut xs = splitAt (length xs `div` 2) xs

riffle :: [a] -> [a] -> [a]
riffle xs [] = xs
riffle [] ys = ys
riffle (x : xs) (y : ys) = x : y : riffle xs ys
