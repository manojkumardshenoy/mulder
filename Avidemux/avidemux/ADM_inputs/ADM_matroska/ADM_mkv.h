/***************************************************************************
                          ADM_pics.h  -  description
                             -------------------
    begin                : Mon Jun 3 2002
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



#ifndef ADM_MKV_H
#define ADM_MKV_H

#include "ADM_editor/ADM_Video.h"
#include "ADM_audio/aviaudio.hxx"
#include "ADM_inputs/ADM_matroska/ADM_ebml.h"


typedef struct
{
    uint64_t pos;
    uint32_t size;
    uint32_t flags;
    uint32_t timeCode;  // In fact it is delta between DTS and PTS for audio...
}mkvIndex;
//**********************************************
typedef struct
{
  /* Index in mkv */
  uint32_t  streamIndex;

  /* Used for audio */
  WAVHeader wavHeader;
  uint32_t  nbPackets; // number of blocks (used for audio)
  uint32_t  nbFrames;  // number of distinct frames
  uint32_t  length;
  /* Used for both */
  uint8_t    *extraData;
  uint32_t   extraDataLen;
  mkvIndex  *_index;
  uint32_t  _nbIndex;  // current size of the index
  uint32_t  _indexMax; // Max size of the index
  uint32_t  _sizeInBytes; // Approximate size in bytes of that stream
  uint32_t  _defaultFrameDuration; // Duration of ONE frame in us!
}mkvTrak;

#define MKV_MAX_LACES 31 // ?
//**********************************************
class mkvAudio : public AVDMGenericAudioStream
{
  protected:
    mkvTrak                     *_track;
    ADM_ebml_file               *_parser;
    ADM_ebml_file               *_clusterParser;
    mkvIndex                    *_clusters;
    uint32_t                    _nbClusters;
    uint32_t                    _currentCluster;

    uint32_t                    _frameDurationInSample; // Nb Samples per frame
    uint32_t                    _currentLace;
    uint32_t                    _maxLace;
    uint32_t                    _Laces[MKV_MAX_LACES];

    uint8_t                     goToCluster(uint32_t x);
    uint8_t                     getPacket(uint8_t *dest, uint32_t *packlen, uint32_t *samples,uint32_t *timecode);
    uint32_t                    _curTimeCode;
  public:
                                mkvAudio(const char *name,mkvTrak *track,mkvIndex *clust,uint32_t nbClusters);


    virtual                     ~mkvAudio();
    virtual uint32_t            read(uint32_t len,uint8_t *buffer);
    virtual uint8_t             goTo(uint32_t newoffset);
            uint8_t	        goToTime(uint32_t mstime);
    virtual uint8_t             getPacket(uint8_t *dest, uint32_t *len, uint32_t *samples);
  //  virtual uint8_t             goToTime(uint32_t mstime);
    virtual uint8_t             extraData(uint32_t *l,uint8_t **d);
};


#define ADM_MKV_MAX_TRACKS 20

class mkvHeader         :public vidHeader
{
  protected:

    ADM_ebml_file           *_parser;
    char                    *_filename;
    mkvTrak                 _tracks[ADM_MKV_MAX_TRACKS+1];

    mkvIndex                    *_clusters;
    uint32_t                    _nbClusters;
    uint32_t                    _clustersCeil;

    uint32_t                _nbAudioTrack;
    uint32_t                _currentAudioTrack;
    uint32_t                _reordered;

    uint8_t                 checkHeader(void *head,uint32_t headlen);
    uint8_t                 analyzeTracks(void *head,uint32_t headlen);
    uint8_t                 analyzeOneTrack(void *head,uint32_t headlen);
    uint8_t                 walk(void *seed);
    int                     searchTrackFromTid(uint32_t tid);
    //
    uint8_t                 reformatVorbisHeader(mkvTrak *trk);
    // Indexers

    uint8_t                 addIndexEntry(uint32_t track,ADM_ebml_file *parser,uint64_t where, 
                                            uint32_t size,uint32_t flags,  uint32_t timecodeMS);
    uint8_t                 videoIndexer(ADM_ebml_file *parser);
    uint8_t                 readCue(ADM_ebml_file *parser);
    uint8_t                 indexClusters(ADM_ebml_file *parser);
    uint8_t                 indexBlock(ADM_ebml_file *parser,uint32_t count,uint32_t timecodeMS);

    uint8_t                 changeAudioStream(uint32_t newstream);
    uint32_t                getCurrentAudioStreamNumber(void);
    uint8_t                 getAudioStreamsInfo(uint32_t *nbStreams, audioInfo **infos);
    uint8_t                 rescaleTrack(mkvTrak *track,uint32_t durationMs);
  public:

      uint8_t               hasPtsDts(void) {return 1;} // Return 1 if the container gives PTS & DTS info
      uint32_t              ptsDtsDelta(uint32_t framenum);

    virtual   void          Dump(void);

            mkvHeader( void );
   virtual  ~mkvHeader(  ) ;
// AVI io
    virtual uint8_t  open(const char *name);
    virtual uint8_t  close(void) ;
  //__________________________
  //  Info
  //__________________________

  //__________________________
  //  Audio
  //__________________________

    virtual   WAVHeader *getAudioInfo(void ) ;
    virtual uint8_t getAudioStream(AVDMGenericAudioStream **audio);


// Frames
  //__________________________
  //  video
  //__________________________

    virtual uint8_t  setFlag(uint32_t frame,uint32_t flags);
    virtual uint32_t getFlags(uint32_t frame,uint32_t *flags);
    virtual uint8_t  getFrameNoAlloc(uint32_t framenum,ADMCompressedImage *img);

            uint8_t  getExtraHeaderData(uint32_t *len, uint8_t **data);
            uint8_t  isReordered( void );
            uint8_t  reorder( void );

};
#endif


