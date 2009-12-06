/**
        \file audio_encoderWrapper.cpp
        \bried proxy between AUDMEncoder class and AVDMGenericAudioStream

*/

#include "ADM_default.h"
#include "ADM_coreAudio.h"

#include "audioencoder.h"

#include "audio_encoderWrapper.h"

/**
    \fn ADM_audioEncoderWrapper
    \brief Constructor to wrap an encoder inside ADMgenericblah blah

*/
ADM_audioEncoderWrapper::ADM_audioEncoderWrapper( AUDMEncoder *coder) : AVDMGenericAudioStream()
{
    _wavheader=new WAVHeader;
    memcpy(_wavheader,coder->_wavheader,sizeof(WAVHeader));
    _encoder=coder;
}
/**
    \fn ~ADM_audioEncoderWrapper
    \brief Destructor

*/

ADM_audioEncoderWrapper::~ADM_audioEncoderWrapper()
{
    if(_encoder) delete _encoder;
    if(_wavheader) delete _wavheader;
    _encoder=NULL;
    _wavheader=NULL;
}
/**
    \fn getPacket
    \brief Trampoline

*/

uint8_t		ADM_audioEncoderWrapper::getPacket(uint8_t *dest, uint32_t *len, uint32_t *samples)
{
    ADM_assert(_encoder);
    return _encoder->getPacket(dest,len,samples);
}
/**
    \fn packetPerFrame
    \brief Trampoline

*/
uint8_t     ADM_audioEncoderWrapper::packetPerFrame( void)
{
    ADM_assert(_encoder);
    return _encoder->packetPerFrame();
}
/**
    \fn read
    \brief Trampoline

*/
uint32_t	ADM_audioEncoderWrapper::read(uint32_t size,uint8_t *ptr)
{
    ADM_assert(_encoder);
    return _encoder->read(size,ptr);
}
/**
    \fn extraData
    \brief Trampoline

*/
uint8_t		ADM_audioEncoderWrapper::extraData(uint32_t *l,uint8_t **d)
{

    ADM_assert(_encoder);
    return _encoder->extraData(l,d);

}
/**
    \fn isVBR
    \brief Trampoline
*/
uint8_t  	ADM_audioEncoderWrapper::isVBR(void )
{
    ADM_assert(_encoder);
    return _encoder->isVBR();
}
//EOF