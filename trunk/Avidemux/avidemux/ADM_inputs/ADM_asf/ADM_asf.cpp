/***************************************************************************
    copyright            : (C) 2006 by mean
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
#include "config.h"

#include <math.h>

#include "ADM_default.h"
#include "ADM_editor/ADM_Video.h"
#include "ADM_assert.h"

#include "fourcc.h"
#include "DIA_coreToolkit.h"
//#include "DIA_working.h"
#include "ADM_asf.h"
#include "ADM_asfPacket.h"

#include "ADM_osSupport/ADM_debugID.h"
#define MODULE_NAME MODULE_ASF
#include "ADM_osSupport/ADM_debug.h"

static const uint8_t asf_audio[16]={0x40,0x9e,0x69,0xf8,0x4d,0x5b,0xcf,0x11,0xa8,0xfd,0x00,0x80,0x5f,0x5c,0x44,0x2b};
static const uint8_t asf_video[16]={0xc0,0xef,0x19,0xbc,0x4d,0x5b,0xcf,0x11,0xa8,0xfd,0x00,0x80,0x5f,0x5c,0x44,0x2b};


WAVHeader *asfHeader::getAudioInfo(void )
{
  if(!_curAudio) return NULL;
  return _curAudio->getInfo();
}
/*
    __________________________________________________________
*/

uint8_t asfHeader::getAudioStream(AVDMGenericAudioStream **audio)
{
 
  *audio=_curAudio;
  return 1; 
}
/*
    __________________________________________________________
*/

void asfHeader::Dump(void)
{
 
  printf("*********** ASF INFO***********\n");
}
/*
    __________________________________________________________
*/

uint8_t asfHeader::close(void)
{
	if (_fd) 
		fclose(_fd);

	_fd=NULL;

  if(_videoExtraData)
  {
    delete [] _videoExtraData;
    _videoExtraData=NULL; 
  }
  if(myName)
  {
    delete myName;
    myName=NULL; 
  }
  if(_extraData)
  {
    delete [] _extraData;
    _extraData=NULL; 
  }
  if(_packet)
    delete _packet;
  _packet=NULL;
  
  for(int i=0;i<_nbAudioTrack;i++)
  {
    asfAudioTrak *trk=&(_allAudioTracks[i]);
    if(trk->extraData) delete [] trk->extraData;
    trk->extraData=NULL;
  }
}
uint8_t       asfHeader::getExtraHeaderData(uint32_t *len, uint8_t **data)
{
  *len=_extraDataLen;
  *data=_extraData;
  return 1; 
}
/*
    __________________________________________________________
*/

 asfHeader::asfHeader( void ) : vidHeader()
{
  _fd=NULL;
  _videoIndex=-1;
  myName=NULL;
  _extraDataLen=0;
  _extraData=NULL;
  _packetSize=0;
  _videoStreamId=0;
  _packet=NULL;
  _curAudio=NULL;
  _nbPackets=0;
  printf("%u\n",sizeof(_allAudioTracks));
  memset(&(_allAudioTracks[0]),0,sizeof(_allAudioTracks));

  _nbAudioTrack=0;
  _currentAudioStream=0;
}
/*
    __________________________________________________________
*/

 asfHeader::~asfHeader(  )
{
  close();
}
/*
    __________________________________________________________
*/

uint8_t asfHeader::open(const char *name)
{
  _fd=fopen(name,"rb");
  if(!_fd)
  {
    GUI_Error_HIG("File Error.","Cannot open file\n");
    return 0; 
  }
  myName=ADM_strdup(name);
  if(!getHeaders())
  {
    return 0; 
  }
  buildIndex();
  fseeko(_fd,_dataStartOffset,SEEK_SET);
  _packet=new asfPacket(_fd,_nbPackets,_packetSize,&readQueue,_dataStartOffset);
  curSeq=1;
  if(_nbAudioTrack)
  {
    _curAudio=new asfAudio(this,_currentAudioStream);
  }
  return 1;
}
/*
    __________________________________________________________
*/

 
/*
    __________________________________________________________
*/

  uint8_t  asfHeader::setFlag(uint32_t frame,uint32_t flags)
{
  ADM_assert(frame<_index.size());
  _index[frame].flags=flags;
  return 1; 
}
/*
    __________________________________________________________
*/

uint32_t asfHeader::getFlags(uint32_t frame,uint32_t *flags)
{
  if(frame>=_index.size()) return 0;
  if(!frame) *flags=AVI_KEY_FRAME;
  else 
      *flags=_index[frame].flags;
  return 1; 
}
/*
    __________________________________________________________
*/

uint8_t  asfHeader::getFrameNoAlloc(uint32_t framenum,ADMCompressedImage *img)
{
  img->dataLength=0;
  img->flags=AVI_KEY_FRAME;
  if(framenum>=_index.size())
  {
    printf("[ASF] Going out of bound %u %u\n",framenum, _index.size());
    return 0;
  }
  if(!_index[framenum].frameLen)
  {
    return 1; // Empty frame 
  }
  // In case curSeq is stored as one byte..
  curSeq&=0xff;
  //
  uint32_t len=0;
  aprintf("Framenum %u len: %u curSeq %u frameSeq=%u packetnb=%u \n",
         framenum,_index[framenum].frameLen,curSeq,
         _index[framenum].segNb,_index[framenum].packetNb);
  // Seeking ?
  if(_index[framenum].segNb!=curSeq)
  {
    printf("Seeking.. curseq:%u wanted seq:%u\n",curSeq,_index[framenum].segNb);
    if(!_packet->goToPacket(_index[framenum].packetNb))
    {
      printf("[ASF] Cannot seek to frame %u\n",framenum);
      return 0; 
    }
    _packet->purge();
    curSeq=_index[framenum].segNb;
    printf("Seeking starting at seq=%u\n",curSeq);
  }
  
  
  len=0;
  uint32_t delta;
  while(1)
  {
   
    
    
    while(!readQueue.isEmpty())
    {
      asfBit *bit;
      ADM_assert(readQueue.pop((void**)&bit));
      aprintf(">found packet of size %d seq %d, while curseq =%d wanted seg=%u current offset=%u\n",bit->len,bit->sequence,curSeq,_index[framenum].segNb,len);
      // Here it is tricky
      // if len==0 we are reading the first part of our frame
      // The packet may starts with segments from the previous frame
      // discard them
      // Delta is just a security as it should be slightly >10
      delta=256+bit->sequence-_index[framenum].segNb;
      delta &=0xff;
      if(!len) // Starting a new frame
      {
          if(_index[framenum].segNb != bit->sequence )
          {
            aprintf("Dropping seq=%u too old for %u delta %d\n",
                  bit->sequence,_index[framenum].segNb,delta);
            delete[] bit->data;
            delete bit;
            if(delta<230)
            {
              printf("Very suspicious\n");
              printf("Very suspicious\n");
              printf("Very suspicious\n");
              printf("Very suspicious\n");
              printf("Very suspicious\n");
            }
            continue; 
          }
          // We have found our first chunk
          curSeq=bit->sequence;
          memcpy(img->data,bit->data,bit->len);
          len=bit->len;
          delete[] bit->data;
          delete bit;
          continue;
      }
      // Continuing a frame
      // If the seq number is different it is the beginning of a new frame
      if(bit->sequence!=curSeq )
      {
        aprintf("New sequence %u->%u while loading %u frame\n",curSeq,bit->sequence,framenum);
        img->dataLength=len;
        readQueue.pushBack(bit); // don't delete it, we will use it later...
        curSeq=bit->sequence;
        goto gotcha;
      }
      // still same sequence ...add
      memcpy(img->data+len,bit->data,bit->len);
      len+=bit->len;
	  delete[] bit->data;
      delete bit;
    }
    if(!_packet->nextPacket(_videoStreamId))
    {
      printf("[ASF] Packet Error\n");
      return 0; 
    }
    _packet->skipPacket();
  }
gotcha:
  
  img->dataLength=len;
  if(len!=_index[framenum].frameLen)
  {
    printf("[ASF] Frame=%u :-> Mismatch found len : %u expected %u\n",framenum,len, _index[framenum].frameLen);
  }
  aprintf(">>Len %d seq %d\n",len,curSeq);
  return 1; 
}
/*
    __________________________________________________________
*/

/*******************************************
  Read Headers to collect information 
********************************************/
uint8_t asfHeader::getHeaders(void)
{
  uint32_t i=0,nbSubChunk,hi,lo;
  const chunky *id;
  uint8_t gid[16];
  uint32_t mn=0,mx=0;
  asfChunk chunk(_fd);
  // The first header is header chunk
  chunk.nextChunk();
  id=chunk.chunkId();
  if(id->id!=ADM_CHUNK_HEADER_CHUNK)
  {
    printf("[ASF] expected header chunk\n"); 
    return 0;
  }
  printf("[ASF] getting headers\n");
  chunk.dump();
  nbSubChunk=chunk.read32();
  printf("NB subchunk :%u\n",nbSubChunk);
  chunk.read8();
  chunk.read8();
  for(i=0;i<nbSubChunk;i++)
  {
    asfChunk *s=new asfChunk(_fd);
    uint32_t skip;
    s->nextChunk();
    printf("***************\n");  
    id=s->chunkId();
    s->dump();
    switch(id->id)
    {
#if 0      
      case ADM_CHUNK_HEADER_EXTENSION_CHUNK:
      {
        s->skip(16); // Clock type extension ????
        printf("?? %d\n",s->read16());
        printf("?? %d\n",s->read32());
          
        uint32_t streamNameCount;
        uint32_t payloadCount;
          
          asfChunk *u=new asfChunk(_fd);
          for(int zzz=0;zzz<8;zzz++)
          {
              u->nextChunk();
              u->dump();
              id=u->chunkId();
              if(id->id==ADM_CHUNK_EXTENDED_STREAM_PROP)
              {
                  s->skip(8); // start time 
                  s->skip(8); // end time
                  printf("Bitrate         %u :\n",u->read32());
                  printf("Buffer Size     %u :\n",u->read32());
                  printf("BFill           %u :\n",u->read32());
                  printf("Alt Bitrate     %u :\n",u->read32());
                  printf("Alt Bsize       %u :\n",u->read32());
                  printf("Alt Bfullness   %u :\n",u->read32());
                  printf("Max object Size %u :\n",u->read32());
                  printf("Flags           0x%x :\n",u->read32());
                  printf("Stream no       %u :\n",u->read16());
                  printf("Stream lang     %u :\n",u->read16());
                  printf("Stream time/fra %lu :\n",u->read64());
                  streamNameCount=u->read16();
                  payloadCount=u->read16();
                  printf("Stream Nm Count %u :\n",streamNameCount);
                  printf("Payload count   %u :\n",payloadCount);
                  for(int stream=0;stream<streamNameCount;stream++)
                  {
                    u->read16();
                    skip=u->read16();
                    u->skip(skip);
                  }
                  uint32_t size;
                  for(int payload=0;payload<payloadCount;payload++)
                  {
                    for(int pp=0;pp<16;pp++) printf("0x%02x,",u->read8());
                    printf("\n");
                    skip=u->read16();
                    size=u->read32();
                    u->skip(size);
                    printf("Extra Data : %d, skipd %d\n",size,skip);
                  }
                  printf("We are at %x\n",ftello(_fd));
                }
                u->skipChunk();
          }
          delete u;
      }
      break;
#endif      
      case ADM_CHUNK_FILE_HEADER_CHUNK:
        {
            // Client GID
            printf("Client        :");
            for(int z=0;z<16;z++) printf(":%02x",s->read8());
            printf("\n");
            printf("File size     : %08lx\n",s->read64());
            printf("Creation time : %08lx\n",s->read64());
            printf("Number of pack: %08lx\n",s->read64());
            printf("Timestamp 1   : %08lx\n",s->read64());
            _duration=s->read64();
            printf("Timestamp 2   : %08lx\n",_duration);
            printf("Timestamp 3   : %04x\n",s->read32());
            printf("Preload       : %04x\n",s->read32());
            printf("Flags         : %04x\n",s->read32());
            mx=s->read32();
            mn=s->read32();
            if(mx!=mn)
            {
              printf("Variable packet size!!\n");
              delete s;
              return 0; 
            }
            _packetSize=mx;
            printf("Min size      : %04x\n",mx);
            printf("Max size      : %04x\n",mn);
            printf("Uncompres.size: %04x\n",s->read32());
          }
          break;
      case ADM_CHUNK_STREAM_HEADER_CHUNK:
      {
         // Client GID
        uint32_t audiovideo=0; // video=1, audio=2, 0=unknown
        uint32_t sid;
        s->read(gid,16);
        printf("Type            :");
        for(int z=0;z<16;z++) printf("0x%02x,",gid[z]);
        if(!memcmp(gid,asf_video,16))
        {
          printf("(video)");
          audiovideo=1;
        } else
        {
          if(!memcmp(gid,asf_audio,16))
          {
            printf("(audio)"); 
            audiovideo=2;
          } else printf("(? ? ? ?)"); 
        }
        printf("\nConceal       :");
        for(int z=0;z<16;z++) printf(":%02x",s->read8());
        printf("\n");
        printf("Reserved    : %08x\n",s->read64());
        printf("Total Size  : %04x\n",s->read32());
        printf("Size        : %04x\n",s->read32());
        sid=s->read16();
        printf("Stream nb   : %04x\n",sid);
        printf("Reserved    : %04x\n",s->read32());
        switch(audiovideo)
        {
          case 1: // Video
          {
                    _videoStreamId=sid;
                    if(!loadVideo(s))
                    {
                      delete s;
                      return 0; 
                    }
                    break;
          }
              break;
          case 2: // audio
          {
            asfAudioTrak *trk=&(_allAudioTracks[_nbAudioTrack]);
            ADM_assert(_nbAudioTrack<ASF_MAX_AUDIO_TRACK);
            trk->streamIndex=sid;
            s->read((uint8_t *)&(trk->wavHeader),sizeof(WAVHeader));

		#ifdef ADM_BIG_ENDIAN
			Endian_WavHeader(&(trk->wavHeader));
		#endif

            trk->extraDataLen=s->read16();
            printf("Extension :%u bytes\n",trk->extraDataLen);
            if(trk->extraDataLen)
            {
              trk->extraData=new uint8_t[trk->extraDataLen];
              s->read(trk->extraData,trk->extraDataLen);
            }
              printf("#block in group   :%d\n",s->read8());
              printf("#byte in group    :%d\n",s->read16());
              printf("Align1            :%d\n",s->read16());
              printf("Align2            :%d\n",s->read16());
              _nbAudioTrack++;
            
          }
          break;
          default:break; 
          
        }
      }
      break;
       default:
         break;
    }
    s->skipChunk();
    delete s;
  }
  printf("End of headers\n");
  return 1;
}
uint8_t    asfHeader::changeAudioStream(uint32_t newstream)
{
  ADM_assert(_currentAudioStream<_nbAudioTrack);
  _currentAudioStream=newstream;
  return 1;
}
uint32_t    asfHeader::getCurrentAudioStreamNumber(void)
{
  return _currentAudioStream;
}
uint8_t     asfHeader::getAudioStreamsInfo(uint32_t *nbStreams, audioInfo **infos)
{
    *nbStreams=_nbAudioTrack;
    if(_nbAudioTrack)
    {
      *infos=new audioInfo[_nbAudioTrack];
      for(int i=0;i<_nbAudioTrack;i++)
      {
        WAV2AudioInfo(&(_allAudioTracks[i].wavHeader),&((*infos)[i]));
      }
    }
    return 1;
}
uint8_t asfHeader::loadVideo(asfChunk *s)
{
  uint32_t w,h,x;
            w=s->read32();
            h=s->read32();
            s->read8();
            x=s->read16();
            _isvideopresent=1;

            memset(&_mainaviheader,0,sizeof(_mainaviheader));
            _mainaviheader.dwWidth=w;
            _mainaviheader.dwHeight=h;
            _video_bih.biWidth=w;
            _video_bih.biHeight=h;
            printf("Pic Width  %04d\n",w);
            printf("Pic Height %04d\n",h);
            printf(" BMP size  %04d (%04d)\n",x,sizeof(ADM_BITMAPINFOHEADER));
            s->read((uint8_t *)&_video_bih,sizeof(ADM_BITMAPINFOHEADER));

		#ifdef ADM_BIG_ENDIAN
			Endian_BitMapInfo(&_video_bih);
		#endif

            _videostream.dwScale=1000;
            _videostream.dwRate=30000;

            _videostream.fccHandler=_video_bih.biCompression;
            printf("Codec : <%s> (%04x)\n",
                    fourCC::tostring(_video_bih.biCompression),_video_bih.biCompression);
            if(fourCC::check(_video_bih.biCompression,(uint8_t *)"DVR "))
            {
              // It is MS DVR, fail so that the mpeg2 indexer can take it from here
              _videostream.fccHandler=_video_bih.biCompression=fourCC::get((uint8_t *)"MPEG");
              printf("This is MSDVR, not ASF\n");
              return 0; 
            }
            printBih(&_video_bih);
            if(x>sizeof(ADM_BITMAPINFOHEADER))
            {
              _extraDataLen=x-sizeof(ADM_BITMAPINFOHEADER);
              _extraData=new uint8_t[_extraDataLen];
              s->read(_extraData,_extraDataLen);
            }
            return 1;
}
/*
    Scan the file to build an index
    
    Header Chunk
            Chunk
            Chunk
            Chunk
            
    Data chunk
            Chunk
            Chunk
            
    We skip the 1st one, and just read the header of the 2nd one
    
*/
uint8_t asfHeader::buildIndex(void)
{
  uint32_t fSize;
  const chunky *id;
  uint32_t chunkFound;
  uint32_t r=5;
  uint32_t len;
  
  fseeko(_fd,0,SEEK_END);
  fSize=ftello(_fd);
  fseeko(_fd,0,SEEK_SET);
  
  asfChunk h(_fd);
  printf("[ASF] ********** Building index **********\n");
  printf("[ASF] Searching data\n");
  while(r--)
  {
    h.nextChunk();    // Skip headers
    id=h.chunkId();
    h.dump();
    if(id->id==ADM_CHUNK_DATA_CHUNK) break;
    h.skipChunk();
  }
  if(id->id!=ADM_CHUNK_DATA_CHUNK) return 0;
  // Remove leftover from DATA_chunk
 // Unknown	GUID	16
//       Number of packets	UINT64	8
//       Unknown	UINT8	1
//       Unknown	UINT8	1
//   
  h.read32();
  h.read32();
  h.read32();
  h.read32();
  _nbPackets=(uint32_t) h.read64();
  h.read16();
  
  len=h.chunkLen-16-8-2-24;
  
  printf("[ASF] nbPacket  : %u\n",_nbPackets);
  printf("[ASF] len to go : %u\n",len);
  printf("[ASF] scanning data\n");
  _dataStartOffset=ftello(_fd);
  
  // Here we go
  //DIA_working *working=new DIA_working("indexing asf");
  asfPacket *aPacket=new asfPacket(_fd,_nbPackets,_packetSize,
                                   &readQueue,_dataStartOffset);
  uint32_t packet=1;
#define MAXIMAGE (_nbPackets)
  uint32_t sequence=1;
  uint32_t ceilImage=MAXIMAGE;

  
  asfIndex *tmpIndex=new asfIndex[ceilImage];
  memset(tmpIndex,0,sizeof(asfIndex)*ceilImage);
  len=0;
  asfIndex currentIndex;
  memset(&currentIndex,0,sizeof(currentIndex));
  currentIndex.segNb=1;
  bool first=true;
  while(packet<_nbPackets)
  {
    while(!readQueue.isEmpty())
    {
      asfBit *bit=NULL;
      ADM_assert(readQueue.pop((void**)&bit));
      if(bit->stream==_videoStreamId)
      {
          aprintf(">found packet of size %d seq %d, while curseq =%d\n",bit->len,bit->sequence,curSeq);
          if(first==true)
          {
            currentIndex.segNb=sequence=bit->sequence;
            currentIndex.flags=AVI_KEY_FRAME;
            first=false;
          }else
          if(bit->sequence!=sequence)
          {
            currentIndex.frameLen=len;
            aprintf("New sequence\n");
            if( ((sequence+1)&0xff)!=(bit->sequence&0xff))
            {
                printf("!!!!!!!!!!!! non continuous sequence %u %u\n",sequence,bit->sequence); 
    #if 1         
                // Let's insert a couple of null frame
                int32_t delta,start,end;
                
                start=256+bit->sequence-sequence-1;
                start&=0xff;
                printf("!!!!!!!!!!!! Delta %d\n",start);
                
                
                if(start)
                {
                    asfIndex fillerIndex;
                    memset(&fillerIndex,0,sizeof(fillerIndex));
                    for(int filler=0;filler<start;filler++)
                       _index.push_back(fillerIndex);
                }
    #endif            
           }
            _index.push_back(currentIndex);
            aprintf("Adding new packet of size %u\n",currentIndex.frameLen);
            memset(&currentIndex,0,sizeof(currentIndex));
            
            // Start a new one
            
            currentIndex.frameLen=0;
            currentIndex.segNb=bit->sequence;
            currentIndex.packetNb=bit->packet;
            currentIndex.flags=bit->flags;

            for(int z=0;z<_nbAudioTrack;z++)
            {
              currentIndex.audioSeen[z]=_allAudioTracks[z].length;
            }
            readQueue.pushBack(bit);
    
            sequence=bit->sequence;
            len=0;
            continue;
          }
          len+=bit->len;
      } // End of video stream Id
      else  // Audio ?
      {
        int found=0;
        for(int i=0;i<_nbAudioTrack && !found;i++)
        {
          if(bit->stream == _allAudioTracks[i].streamIndex)
          {
            _allAudioTracks[i].length+=bit->len;
            found=1;
          }
        }
        if(!found) 
        {
          printf("Unmapped stream %u\n",bit->stream); 
        }
      }
     delete[] bit->data;
     delete bit;
    }
    //working->update(packet,_nbPackets);
    packet++;
    aPacket->nextPacket(0xff); // All packets
    aPacket->skipPacket();
  }
  delete aPacket;
  
  fseeko(_fd,_dataStartOffset,SEEK_SET);
  printf("[ASF] %u images found\n",_index.size());
  printf("[ASF] ******** End of buildindex *******\n");
  for(int i=0;i<10;i++)
        printf("%d %d flags:%x\n",i,_index[i].frameLen,_index[i].flags);

  _videostream.dwLength=_mainaviheader.dwTotalFrames=_index.size();
  if(!_index.size()) return 0;
  
  // Update fps
  // In fact it is an average fps
  // FIXME
  float f=_index.size();
  uint32_t ps;
  
  f*=1000.*1000.*10000.;
  f=f/_duration;
  ps=(uint32_t)f;
  // Round up to the closed 0.5 = 500
  ps=(ps+490)/500;
  ps*=500;
  
  _videostream.dwScale=1000;
  _videostream.dwRate=ps;

  return 1;
  
}
//EOF
