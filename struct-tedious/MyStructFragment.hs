{-# LANGUAGE ForeignFunctionInterface #-}

module MyStruct where

import Foreign.Ptr
import Foreign.Storable
import Foreign.C.Types

foreign export ccall foo :: MyStruct -> Int

foo :: MyStruct -> Int
foo = const 42

foreign export ccall showStruct :: MyStruct -> IO ()

showStruct :: MyStruct -> IO ()
showStruct ss = peek ss >>= print

data MyStructType = MyStructType CInt CChar
    deriving (Eq, Ord, Show, Read)

type MyStruct = Ptr MyStructType

