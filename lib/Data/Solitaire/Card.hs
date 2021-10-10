module Data.Solitaire.Card where

data Card = Card
  { cardValue :: Value,
    cardSuit :: Suit
  }
  deriving (Eq)

instance Ord Card where
  compare (Card lhs _) (Card rhs _) = compare lhs rhs

data Suit
  = Clubs
  | Diamonds
  | Hearts
  | Spades
  deriving (Eq)

instance Show Suit where
  show Clubs = "C"
  show Diamonds = "D"
  show Hearts = "H"
  show Spades = "S"

data Value
  = Pips Int
  | Face Face
  deriving (Eq)

instance Enum Value where
  fromEnum (Pips n) = n
  fromEnum (Face f) = 11 + fromEnum f
  toEnum n
    | n >= 11 = Face (toEnum (n - 11))
    | n >= 2 = Pips n
    | otherwise = Pips 2

instance Ord Value where
  compare (Pips _) (Face _) = LT
  compare (Face _) (Pips _) = GT
  compare (Pips x) (Pips y) = compare x y
  compare (Face x) (Face y) = compare x y

instance Show Value where
  show (Pips n) = show n
  show (Face f) = show f

data Face
  = Jack
  | Queen
  | King
  | Ace
  deriving (Enum, Eq, Ord)

instance Show Face where
  show Jack = "J"
  show Queen = "Q"
  show King = "K"
  show Ace = "A"
