Expressing left fold through right fold
=======================================

Derivation
----------

The definition of the right fold

~~~haskell
myFoldr :: (b -> a -> a) -> a -> [b] -> a
myFoldr f z [] = z
myFoldr f z (x:xs) = f x (myFoldr f z xs)
~~~


The definition of the left fold:

~~~haskell
myFoldl :: (a -> b -> a) -> a -> [b] -> a
myFoldl f z [] = z
myFoldl f z (x:xs) = myFoldl f (f z x) xs
~~~


Using an accumulator function a la SICP, we rewrite it as

~~~haskell
myFoldl' :: (a -> b -> a) -> a -> [b] -> a
myFoldl' f z xs = g z xs where
  g y []     = z
  g y (x:xs) = g (f y x) xs
~~~

Swapping the arguments of the accumulator

~~~haskell
myFoldl'' :: (a -> b -> a) -> a -> [b] -> a
myFoldl'' f z xs = g xs z where
  g [] y     = z
  g (x:xs) y = g xs (f y x)
~~~

stripping the second argument of g

~~~haskell
myFoldl''' :: (a -> b -> a) -> a -> [b] -> a
myFoldl''' f z xs = g xs z where
  g []     = id
  g (x:xs) = \y -> g xs (f y x)
~~~


Due to the universal property of fold (Hutton 1999) I have

~~~
g [] = v
                          <=>   g = fold f' v
g (x:xs) = f' x (g xs)
~~~

I'm now seeking to find `f'` and `v`. From the eqs above follows

~~~
v = id
~~~

and

~~~
f' x (g xs)   = \y -> g xs (f y x) =>
f' x (g xs) y = g xs (f y x) =>
f' x k y      = k (f y x) =>
f'            = \x k y -> k (f y x)
~~~

where I substituted `k = g xs`, hence

~~~
g = fold f' id
  where f' x k y = k (f y x)
~~~

and I finally obtain

~~~haskell
myFoldl'''' :: (a -> b -> a) -> a -> [b] -> a
myFoldl'''' f z xs = foldr f' id xs z
  where f' x k y  = k (f y x)
~~~

or equivalently

~~~haskell
myFoldl''''' :: (a -> b -> a) -> a -> [b] -> a
myFoldl''''' f z xs = foldr f' id xs z
  where f' x k = \y -> k (f y x)
~~~

Type signature and interpretation of function `f'`
--------------------------------------------------

In the above formulas we have

~~~{.haskell .ignore}
foldr f' id xs :: a -> a
~~~

On the other hand, the generic type signature of `foldr` is given by

~~~{.haskell .ignore}
foldr :: (q -> p -> p) -> p -> [q] -> p
~~~

Comparing the types, we deduce that

~~~
q = b
p = a -> a
~~~

and

~~~{.haskell .ignore}
f' :: b -> (a -> a) -> (a -> a)
~~~

That means that given a list element `x :: b` and a function `k :: a ->
a`, function `f'` returns a new function of type `:: a -> a`, which
given `y` returns `k (f y x)`.

Example
-------

Consider

~~~{.haskell .ignore}
myFoldl''''' (+) 0 [1, 2, 3]
~~~

It expands into

~~~{.haskell .ignore}
myFoldl''''' (+) 0 [1, 2] =
foldr (\x k y -> k ((+) y x)) id [1, 2, 3] 0 =
(foldr (\x k y -> k (y + x)) id [1, 2, 3]) 0
~~~

Let us expand the parenthesized `foldr`:

~~~{.haskell .ignore}
foldr (\x k y -> k (y + x)) id [1, 2, 3] =
(\x k y -> k (y + x))
  1
  (foldr (\x k y -> k(y + x)) id [2, 3]) =
(\x k y -> k (y + x))
  1
  ((\x k y -> k (y + x))
    2
    (foldr (\x k y -> k((+) y x)) id [3])) =
(\x k y -> k (y + x))
  1
  ((\x k y -> k (y + x))
    2
    ((\x k y -> k (y + x))
      3
      (foldr (\x k y -> k (y + x)) id []))) =
(\x k y -> k (y + x))
  1
  ((\x k y -> k (y + x))
    2
    ((\x k y -> k (y + x))
      3
      id)) =
(\x k y -> k ((+) y x))
  1
  ((\x k y -> k (y + x))
    2
    (\y -> id (3 + y))) =
(\x k y -> k ((+) y x))
  1
  ((\x k y -> k (y + x))
    2
    (\y -> 3 + y)) =
(\x k y -> k (y + x))
  1
  (\y -> (\y -> 3 + y) (y + 2)) =
(\x k y -> k (y + x))
  1
  (\y -> 5 + y) =
(\y -> (\y -> 5 + y) (y + 1)) =
\y - > y + 6
~~~

Applying `\y -> y + 6` to `0` results in `6`.
