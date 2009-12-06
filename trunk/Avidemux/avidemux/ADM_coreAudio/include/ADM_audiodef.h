/*


*/
#ifndef AUDIO_DEF
#define AUDIO_DEF
#include <string.h>
typedef struct
{
    uint16_t	encoding;	
    uint16_t	channels;					/* 1 = mono, 2 = stereo */
    uint32_t	frequency;				/* One of 11025, 22050, or 44100 48000 Hz */
    uint32_t	byterate;					/* Average bytes per second */
    uint16_t	blockalign;				/* Bytes per sample block */
    uint16_t	bitspersample;		/* One of 8, 12, 16, or 4 for ADPCM */
} WAVHeader;
void printWavHeader(WAVHeader *hdr);

typedef enum 
{
    CHANNEL_INVALID=0,
    CHANNEL_MONO,
    CHANNEL_STEREO,
    CHANNEL_2F_1R,
    CHANNEL_3F,
    CHANNEL_3F_1R,
    CHANNEL_2F_2R,
    CHANNEL_3F_2R,
    CHANNEL_3F_2R_LFE,
    CHANNEL_DOLBY_PROLOGIC,
    CHANNEL_DOLBY_PROLOGIC2,
    CHANNEL_LAST
} CHANNEL_CONF;

#define MAX_CHANNELS 9

typedef enum 
{
	CHTYP_INVALID=0,
	CHTYP_MONO,
	CHTYP_FRONT_LEFT,
	CHTYP_FRONT_RIGHT,
	CHTYP_FRONT_CENTER,
	CHTYP_REAR_LEFT,
	CHTYP_REAR_RIGHT,
	CHTYP_REAR_CENTER,
	CHTYP_SIDE_LEFT,
	CHTYP_SIDE_RIGHT,
	CHTYP_LFE
}CHANNEL_TYPE;
// returns true if channel mapping is identical
bool ADM_audioCompareChannelMapping(WAVHeader *wh1, WAVHeader *wh2,CHANNEL_TYPE *map1,CHANNEL_TYPE *map2);


typedef struct
{
  const char    *desc;
  CHANNEL_CONF  conf;
}AudioChannelDesc;
const AudioChannelDesc localDownmixing[]=
{
  {"No downmixing (multichannel)", CHANNEL_INVALID},
  {"Stereo", CHANNEL_STEREO},
  {"Dolby Prologic", CHANNEL_DOLBY_PROLOGIC},
  {"Dolby Prologic II", CHANNEL_DOLBY_PROLOGIC2}
  
};
#define NB_LOCAL_DOWNMIX (sizeof(localDownmixing)/sizeof(AudioChannelDesc))
#endif
