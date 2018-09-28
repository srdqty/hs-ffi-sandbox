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

instance Storable MyStructType where
    sizeOf _ = {# sizeof MyStruct #}
    alignment _ = {# alignof MyStruct #}
    peek addr = do
        _foo <- {# get MyStruct.foo #} addr
        _bar <- {# get MyStruct.bar #} addr
        return (MyStructType _foo _bar)
    poke addr (MyStructType _foo _bar) = do
        {# set MyStruct.foo #} addr _foo
        {# set MyStruct.bar #} addr _bar
