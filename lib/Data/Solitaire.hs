module Data.Solitaire
  ( riffleShuffle,
    shuffleM,
  )
where

import System.Random.Shuffle (shuffleM)

riffleShuffle :: Int -> [a] -> [a]
riffleShuffle n = (!! n) . iterate (uncurry riffle . cut)

cut :: [a] -> ([a], [a])
cut xs = splitAt (length xs `div` 2) xs

riffle :: [a] -> [a] -> [a]
riffle xs [] = xs
riffle [] ys = ys
riffle (x : xs) (y : ys) = x : y : riffle xs ys
