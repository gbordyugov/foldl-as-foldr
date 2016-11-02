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
  g z []     = z
  g z (x:xs) = g (f z x) xs
~~~

Swapping the arguments of the accumulator

~~~haskell
myFoldl'' :: (a -> b -> a) -> a -> [b] -> a
myFoldl'' f z xs = g xs z where
  g [] z     = z
  g (x:xs) z = g xs (f z x)
~~~

stripping the second argument of g

~~~haskell
myFoldl''' :: (a -> b -> a) -> a -> [b] -> a
myFoldl''' f z xs = g xs z where
  g []     = id
  g (x:xs) = \z -> g xs (f z x)
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
f' x (g xs)   = \z -> g xs (f z x) =>
f' x (g xs) z = g xs (f z x) =>
f' x k z      = k (f z x) =>
f'            = \x k z -> k (f z x)
~~~

where I substituted `k = g xs`, hence

~~~
g = fold f' id
  where f' x k z = k (f z x)
~~~

and I finally obtain

~~~haskell
myFoldl'''' :: (a -> b -> a) -> a -> [b] -> a
myFoldl'''' f z xs = foldr f' id xs z
  where f' x k z  = k (f z x)
~~~

