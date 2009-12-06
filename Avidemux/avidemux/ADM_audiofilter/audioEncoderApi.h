/**
    \file audioEncoderApi.h
    \brief Helper functions to deal with audioEncoders

*/
#ifndef AUDIOENCODERAPI_H
#define AUDIOENCODERAPI_H

/// Select the best encoder using the audio fourcc : WAV_MP3 etc...
uint8_t audio_selectCodecByTag(uint32_t tag);
/// Set an option for example "DISABLERESERVOIR",1
uint8_t audioSetOption(const char *option, uint32_t value);
/// Select the copy Codec
uint8_t audio_setCopyCodec(void);
/// Directly set the codec, *only to be used
uint8_t audioCodecSetByIndex(int i);
/// Spawn a new encoder
AUDMEncoder *audioEncoderCreate(AUDMAudioFilter *filter);
/// Select a encoder by its name e.g. "lame", used only by JS. Update UI as well
uint8_t audioCodecSetByName( const char *name);
/// Returns the name of the currently selected codec
const char *audioCodecGetName( void );
/// Update the UI with the currently selected codec
void audioPrintCurrentCodec(void);
/// Returns 1 if we are in process mode, 0 if in copy mode
uint32_t audioProcessMode(void);
/// Retrieve current audio encoder configuration
uint8_t getAudioExtraConf(uint32_t *bitrate,uint32_t *extraDataSize, uint8_t **extradata);
/// Set current audio encoder configuration
uint8_t setAudioExtraConf(uint32_t bitrate,uint32_t extraDataSize, uint8_t *extradata);



#endif
// EOF
