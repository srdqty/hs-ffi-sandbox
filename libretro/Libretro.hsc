{-# LANGUAGE ForeignFunctionInterface #-}

module Libretro where

import Foreign
import Foreign.Ptr
import Foreign.C.String
import Foreign.C.Types

#include "libretro.h"

data RetroSystemInfo

foreign import ccall clear_retro_system_info :: Ptr RetroSystemInfo -> IO ()
foreign export ccall retro_get_system_info :: Ptr RetroSystemInfo -> IO ()

-- Tell libretro about this core, it's name, version and which rom file types
-- it supports.
retro_get_system_info addr = do
  -- TODO: what to do about deallocating this
  libraryName <- newCAString "HaskellTest"
  libraryVersion <- newCAString "0.1.0"
  validExtensions <- newCAString "bin|hsr"
  clear_retro_system_info addr
  #{poke struct retro_system_info,library_name} addr libraryName
  #{poke struct retro_system_info,library_version} addr libraryVersion
  #{poke struct retro_system_info,need_fullpath} addr (CBool 0)
  #{poke struct retro_system_info,valid_extensions} addr validExtensions

-- Tell libretro about the AV system; the fps, sound sample rate and the
-- resolution of the display.

data RetroSystemAvInfo

foreign import ccall clear_retro_system_av_info :: Ptr RetroSystemAvInfo -> IO ()
foreign export ccall retro_get_system_av_info :: Ptr RetroSystemAvInfo -> IO ()

retro_get_system_av_info addr = do
    clear_retro_system_av_info addr
    #{poke struct retro_system_av_info,timing.fps} addr (50.0 :: CFloat)
    #{poke struct retro_system_av_info,timing.sample_rate} addr (44100 :: CUInt)
    #{poke struct retro_system_av_info,geometry.base_width} addr (330 :: CUInt)
    #{poke struct retro_system_av_info,geometry.base_height} addr (410 :: CUInt)
    #{poke struct retro_system_av_info,geometry.max_width} addr (330 :: CUInt)
    #{poke struct retro_system_av_info,geometry.max_height} addr (410 :: CUInt)
    #{poke struct retro_system_av_info,geometry.aspect_ratio} addr ((330.0 :: CFloat) / (410.0 :: CFloat))

type RetroEnvironmentT a = CUInt -> Ptr a -> IO CBool

foreign import ccall "dynamic" call_retro_environment_t
  :: FunPtr (RetroEnvironmentT a) -> RetroEnvironmentT a

foreign export ccall retro_set_environment :: FunPtr (RetroEnvironmentT a) -> IO ()

retro_set_environment f = do
  alloca $ \ptr -> do
    poke ptr (1 :: CBool)
    -- RETRO_ENVIRONMENT_SET_SUPPORT_NO_GAME
    call_retro_environment_t f 18 (castPtr ptr)
    return ()

data RetroGameInfo

foreign export ccall retro_load_game :: Ptr RetroGameInfo -> IO CBool

retro_load_game _ = return (CBool 1)

foreign export ccall retro_unload_game :: IO ()

retro_unload_game = return ()

foreign export ccall retro_run :: IO ()

retro_run = return ()

foreign export ccall retro_reset :: IO ()

retro_reset = return ()

{-
/* Sets callbacks. retro_set_environment() is guaranteed to be called
 * before retro_init().
 *
 * The rest of the set_* functions are guaranteed to have been called
 * before the first call to retro_run() is made. */
RETRO_API void retro_set_environment(retro_environment_t);
RETRO_API void retro_set_video_refresh(retro_video_refresh_t);
RETRO_API void retro_set_audio_sample(retro_audio_sample_t);
RETRO_API void retro_set_audio_sample_batch(retro_audio_sample_batch_t);
RETRO_API void retro_set_input_poll(retro_input_poll_t);
RETRO_API void retro_set_input_state(retro_input_state_t);
-}
