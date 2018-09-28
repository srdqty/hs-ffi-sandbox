{-# LANGUAGE ForeignFunctionInterface #-}

module MyStruct where

import Foreign.Ptr
import Foreign.Storable
import Foreign.C.Types

#include "my_struct.h"

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
    sizeOf _ = #{size MyStruct}
    alignment _ = #{alignment MyStruct}
    peek ptr = do
        _foo <- #{peek MyStruct, foo} ptr
        _bar <- #{peek MyStruct, bar} ptr
        return (MyStructType _foo _bar)
    poke ptr (MyStructType _foo _bar) = do
        #{poke MyStruct, foo} ptr _foo
        #{poke MyStruct, bar} ptr _bar
