{-# LANGUAGE ForeignFunctionInterface #-}

import Data.Foldable (traverse_)
import Foreign
import Foreign.C.Types

foreign import ccall "math.h sin"
    c_sin :: CDouble -> CDouble

foreignsin :: Double -> Double
foreignsin = realToFrac . c_sin . realToFrac

main :: IO ()
main = traverse_ (print . foreignsin) [0/10, 1/10 .. 10/10]
