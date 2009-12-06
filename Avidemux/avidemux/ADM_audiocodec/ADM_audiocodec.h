/***************************************************************************
                          ADM_audiocodec.h  -  description
                             -------------------
    begin                : Fri May 31 2002
    copyright            : (C) 2002 by mean
    email                : fixounet@free.fr
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef ADMAUDIOCODEC
#define ADMAUDIOCODEC

#define SCRATCH_PAD_SIZE (100*1000*2)
extern uint8_t scratchPad[];
#define  ADMAC_BUFFER (48000*4)
class ADM_Audiocodec
{
	protected:
		uint8_t	_init;
		WAVHeader *_wavHeader;
	public:
		ADM_Audiocodec(uint32_t fourcc)
		{
			UNUSED_ARG(fourcc);
			_init=0;
		};

		virtual	~ADM_Audiocodec() {};
		virtual	void purge(void) {}
		virtual	uint8_t beginDecompress(void)=0;
		virtual	uint8_t endDecompress(void)=0;
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut)=0;
		virtual	uint8_t isCompressed(void)=0;
		virtual	uint8_t isDecompressable(void)=0;
		// Channel mapping, only input is used by the decoders..
		CHANNEL_TYPE channelMapping[MAX_CHANNELS];
 };

ADM_Audiocodec	*getAudioCodec(uint32_t fourcc, WAVHeader *info, uint32_t extra=0, uint8_t *extraData=NULL);

class ADM_AudiocodecWav : public     ADM_Audiocodec
{
	public:
		ADM_AudiocodecWav(uint32_t fourcc);
		virtual	~ADM_AudiocodecWav();
		virtual	uint8_t beginDecompress(void);
		virtual	uint8_t endDecompress(void);
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t * nbOut);
		virtual	uint8_t isCompressed(void);
		virtual	uint8_t isDecompressable(void);
};

class ADM_AudiocodecWavSwapped : public     ADM_Audiocodec
{
	public:
		ADM_AudiocodecWavSwapped(uint32_t fourcc);
		virtual	~ADM_AudiocodecWavSwapped();
		virtual	uint8_t beginDecompress(void);
		virtual	uint8_t endDecompress(void);
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut);
		virtual	uint8_t isCompressed(void);
		virtual	uint8_t isDecompressable(void);

   };

class ADM_AudiocodecUnknown : public     ADM_Audiocodec
{
	public:
		ADM_AudiocodecUnknown(uint32_t fourcc) : ADM_Audiocodec(fourcc) {}
		~ADM_AudiocodecUnknown() {}
		uint8_t beginDecompress(void) {return 0;}
		uint8_t endDecompress(void) {return 0;}
		uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut) {return 1;}
		uint8_t isCompressed(void) {return 1;}
		uint8_t isDecompressable(void) {return 0;}
};



class ADM_Audiocodec8Bits : public     ADM_Audiocodec
{
	protected:
		uint8_t _unsign;

	public:
		ADM_Audiocodec8Bits(uint32_t fourcc);
		virtual	~ADM_Audiocodec8Bits();
		virtual	uint8_t beginDecompress(void) {return 1;}
		virtual	uint8_t endDecompress(void) {return 1;}
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut);
		virtual	uint8_t isCompressed(void) {return 1;}
		virtual	uint8_t isDecompressable(void) {return 1;}
};



#define ADMWA_BUF (4*1024*16) // 64 kB internal
class ADM_AudiocodecWMA : public     ADM_Audiocodec
{
	protected:
		void *_contextVoid;
		uint8_t _buffer[ ADMWA_BUF];
		uint32_t _tail,_head;
		uint32_t _blockalign;
                uint32_t _channels;

	public:
		ADM_AudiocodecWMA(uint32_t fourcc, WAVHeader *info, uint32_t l, uint8_t *d);
		virtual	~ADM_AudiocodecWMA() ;
		virtual	uint8_t beginDecompress(void);
		virtual	uint8_t endDecompress(void);
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut);
		virtual	uint8_t isCompressed(void) {return 1;}
		virtual	uint8_t isDecompressable(void) {return 1;}
};



 class ADM_AudiocodecUlaw : public     ADM_Audiocodec
 {
 	public:
		ADM_AudiocodecUlaw(uint32_t fourcc, WAVHeader *info);
		virtual	~ADM_AudiocodecUlaw() ;
		virtual	uint8_t beginDecompress(void) {return 1;}
		virtual	uint8_t endDecompress(void) {return 1;}
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut);
		virtual	uint8_t isCompressed(void) {return 1;}
		virtual	uint8_t isDecompressable(void) {return 1;}
};

#define IMA_BUFFER 4096*8
class ADM_AudiocodecImaAdpcm : public     ADM_Audiocodec
{
	protected:
		uint32_t _inStock,_me,_channels;
		int ss_div,ss_mul; // ???
		void *_contextVoid;
		uint8_t _buffer[ IMA_BUFFER];
		uint32_t _head,_tail;

	public:
		ADM_AudiocodecImaAdpcm(uint32_t fourcc, WAVHeader *info);
		virtual	~ADM_AudiocodecImaAdpcm();
		virtual	uint8_t beginDecompress(void) {_head=_tail=0;return 1;}
		virtual	uint8_t endDecompress(void) {_head=_tail=0;return 1;}
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut);
		virtual	uint8_t isCompressed(void) {return 1;}
		virtual	uint8_t isDecompressable(void) {return 1;}
};
class ADM_AudiocodecMsAdpcm : public     ADM_Audiocodec
{
	protected:
		uint32_t _inStock,_me,_channels;
		int ss_div,ss_mul; // ???
		void *_contextVoid;
		uint8_t _buffer[ IMA_BUFFER];
		uint32_t _head,_tail;

	public:
		ADM_AudiocodecMsAdpcm(uint32_t fourcc, WAVHeader *info);
		virtual	~ADM_AudiocodecMsAdpcm();
		virtual	uint8_t beginDecompress(void) {_head=_tail=0;return 1;}
		virtual	uint8_t endDecompress(void) {_head=_tail=0;return 1;}
		virtual	uint8_t run(uint8_t *inptr, uint32_t nbIn, float *outptr, uint32_t *nbOut);
		virtual	uint8_t isCompressed(void) {return 1;}
		virtual	uint8_t isDecompressable(void) {return 1;}
};

#endif
