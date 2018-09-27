{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.ByteString
  ( ByteString
  , empty
  , useAsCString
  )
import Data.ByteString.Internal (toForeignPtr)
import Data.ByteString.Unsafe
  ( unsafeDrop
  , unsafeTake
  )
import Data.Text (Text)
import Data.Text.Encoding (decodeUtf8, encodeUtf8)
import Data.Coerce (coerce)
import Foreign
import Foreign.C.String
import Foreign.C.Types
import System.IO.Unsafe (unsafePerformIO)

#include <pcre.h>

newtype PCREOption = PCREOption { unPCREOption :: CInt }
  deriving (Eq, Show)

instance Semigroup PCREOption where
  (<>) = coerce @(CInt -> CInt -> CInt) (.|.)

instance Monoid PCREOption where
  mempty = coerce @CInt 0
  mappend = (<>)

#{enum PCREOption, PCREOption
  , caseless = PCRE_CASELESS
  , dollar_endonly = PCRE_DOLLAR_ENDONLY
  , dotall = PCRE_DOTALL
  , utf8 = PCRE_UTF8
  }

data PCRE

foreign import ccall unsafe "pcre.h pcre_compile"
  c_pcre_compile :: CString
                 -> PCREOption
                 -> Ptr CString
                 -> Ptr CInt
                 -> Ptr Word8
                 -> IO (Ptr PCRE)

data Regex = Regex !(ForeignPtr PCRE) !Text
  deriving (Eq, Ord, Show)

compile :: Text -> PCREOption -> Either String Regex
compile txt flags = unsafePerformIO $
  useAsCString (encodeUtf8 txt) $ \pattern -> do
    alloca $ \errptr -> do
    alloca $ \erroffset -> do
      pcre_ptr <-
        c_pcre_compile pattern (flags <> utf8) errptr erroffset nullPtr
      if pcre_ptr == nullPtr
        then do
          err <- peekCString =<< peek errptr
          return (Left err)
        else do
          reg <- newForeignPtr finalizerFree pcre_ptr
          return (Right (Regex reg txt))

data PCREExtra

newtype PCREExecOption = PCREExecOption { unPCREExecOption :: CInt }
  deriving (Eq, Show)

instance Semigroup PCREExecOption where
  (<>) = coerce @(CInt -> CInt -> CInt) (.|.)

instance Monoid PCREExecOption where
  mempty = coerce @CInt 0
  mappend = (<>)

foreign import ccall "pcre.h pcre_exec"
  c_pcre_exec :: Ptr PCRE
              -> Ptr PCREExtra
              -> CString
              -> CInt
              -> CInt
              -> PCREExecOption
              -> Ptr CInt
              -> CInt
              -> IO CInt

newtype PCREInfo = PCREInfo { unPCREInfo :: CInt }
  deriving (Eq, Show)

instance Semigroup PCREInfo where
  (<>) = coerce @(CInt -> CInt -> CInt) (.|.)

instance Monoid PCREInfo where
  mempty = coerce @CInt 0
  mappend = (<>)

#{enum PCREInfo, PCREInfo
  , info_capturecount = PCRE_INFO_CAPTURECOUNT
  }

foreign import ccall "pcre.h pcre_fullinfo"
  c_pcre_fullinfo :: Ptr PCRE
                  -> Ptr PCREExtra
                  -> PCREInfo
                  -> Ptr a
                  -> IO CInt

capturedCount :: Ptr PCRE -> IO Int
capturedCount regex_ptr =
  alloca $ \n_ptr -> do
    _ <- c_pcre_fullinfo regex_ptr nullPtr info_capturecount n_ptr
    return . fromIntegral =<< peek (n_ptr :: Ptr CInt)

match :: Regex -> Text -> PCREExecOption -> Maybe [Text]
match (Regex pcre_fp _) txt opts = unsafePerformIO $ do
  withForeignPtr pcre_fp $ \pcre_ptr -> do
    n_capt <- capturedCount pcre_ptr

    let ovec_size = (n_capt + 1) * 3
        ovec_bytes = ovec_size * sizeOf (undefined :: CInt)

    allocaBytes ovec_bytes $ \ovec -> do
      let (str_fp, off, len) = toForeignPtr subject
      withForeignPtr str_fp $ \cstr -> do
        r <- c_pcre_exec
          pcre_ptr
          nullPtr
          (cstr `plusPtr` off)
          (fromIntegral len)
          0
          opts
          ovec
          (fromIntegral ovec_size)
        if r < 0
          then return Nothing
        else
          let
            loop n o acc =
              if n == r
                then return (Just (reverse acc))
              else do
                i <- peekElemOff ovec o
                j <- peekElemOff ovec (o+1)
                let s = substring i j subject
                loop (n+1) (o+2) (decodeUtf8 s : acc)
          in
            loop 0 0 []
  where
    subject = encodeUtf8 txt

    substring :: CInt -> CInt -> ByteString -> ByteString
    substring x y _ | x == y = empty
    substring a b s = end
      where
        start = unsafeDrop (fromIntegral a) s
        end = unsafeTake (fromIntegral (b-a)) start

main :: IO ()
main = do
  let Right r0 = compile "the quick brown fox" mempty
  print $ match r0 "the quick brown fox" mempty
  print $ match r0 "The Quick Brown Fox" mempty
  print $ match r0 "What do you know about the quick brown fox?" mempty

  let Right r1 = compile "a*abc?xyz+pqr{3}ab{2,}xy{4,5}pq{0,6}AB{0,}zz" mempty
  print $ match r1 "abxyzpqrrrabbxyyyypqAzz" mempty
  let Right r2 = compile "^([^!]+)!(.+)=apquxz\\.ixr\\.zzz\\.ac\\.uk$" mempty
  print $ match r2 "abc!pqr=apquxz.ixr.zzz.ac.uk" mempty
