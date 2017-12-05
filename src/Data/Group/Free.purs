module Data.Group.Free (Free(..), free, Signed(..)) where
  
import Prelude

import Data.Foldable (foldr)
import Data.Group (class Group)
import Data.List (List(..), reverse, (:))
import Data.Monoid (class Monoid)

data Signed a = Positive a | Negative a

instance showSigned :: Show a => Show (Signed a) where
  show (Positive x) = "+" <> show x
  show (Negative x) = "-" <> show x

-- Reduce a term of a free group to canonical form.
canonical :: forall a. Eq a => List (Signed a) -> List (Signed a)
canonical = foldr cancelOrPush Nil where
  cancelOrPush x@(Positive x1) y@(Cons (Negative y1) tl) = if x1 == y1 then tl else x : y
  cancelOrPush x@(Negative x1) y@(Cons (Positive y1) tl) = if x1 == y1 then tl else x : y
  cancelOrPush x y = x : y

-- The free group generated by elements of a, up to equality.
newtype Free a = Free (List (Signed a))

-- Lift a value of type a to a value of type Free a
free :: forall a. a -> Free a
free x = Free $ Positive x : Nil

instance showFreeGrp :: Show a => Show (Free a) where
  show (Free x) = show x

instance semigrpFreeGrp :: Eq a => Semigroup (Free a) where 
  append (Free x) (Free y) = Free $ canonical $ x <> y

instance monoidFreeGrp :: Eq a => Monoid (Free a) where
  mempty = Free Nil

instance groupFreeGrp :: Eq a => Group (Free a) where
  ginverse (Free fg) = Free $ reverse $ map flipSign fg where
    flipSign (Positive x) = Negative x
    flipSign (Negative x) = Positive x