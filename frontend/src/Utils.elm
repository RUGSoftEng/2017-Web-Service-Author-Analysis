module Utils exposing ((=>))


(=>) : a -> b -> ( a, b )
(=>) x y =
    ( x, y )
infixl 0 =>
