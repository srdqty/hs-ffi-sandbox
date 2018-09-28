#include <string.h>
#include <HsFFI.h>
#include "libretro.h"

RETRO_API unsigned retro_api_version(void)
{
  return RETRO_API_VERSION;
}

RETRO_API void retro_init(void)
{
  /* According to the FFI, passing NULL is allowed */
  hs_init(NULL, NULL);
}

RETRO_API void retro_deinit(void)
{
  hs_exit();
}

void clear_retro_system_info(struct retro_system_info *info)
{
  if(info) {
    memset(info, 0, sizeof(*info));
  }
}

void clear_retro_system_av_info(struct retro_system_av_info *info)
{
  if(info) {
    memset(info, 0, sizeof(*info));
  }
}
