
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


#ifndef ASF_PACKET_H
#define ASF_PACKET_H

#include "ADM_osSupport/ADM_queue.h"

typedef struct 
{
  uint32_t sequence;
  uint32_t offset;
  uint32_t len;
  uint32_t stream;
  uint32_t packet;
  uint32_t flags;
  uint8_t  *data;
}asfBit;

class asfPacket
{
  protected:
    uint32_t        readVCL(uint32_t bitwise);
    uint8_t         pushPacket(uint32_t flags,uint32_t packetnb,
                                uint32_t offset,uint32_t sequence,uint32_t payloadLen,uint32_t stream);
    uint8_t         skip( uint32_t how);
    FILE            *_fd;
    uint32_t        packetStart;
    uint8_t         segmentId;
    uint32_t        pakSize;
    ADM_queue       *queue;
    uint32_t        _offset;
    uint32_t        currentPacket;
    uint32_t        _startDataOffset;
    uint32_t        _nbPackets;
  public:
    
    asfPacket(FILE *f,uint32_t nbElem,uint32_t pSize,ADM_queue *q,uint32_t startDataOffset);
    ~asfPacket();
    uint8_t   dump(void);
    
    uint8_t   goToPacket(uint32_t packet);
  
    uint8_t   readChunkPayload(uint8_t *data, uint32_t *dataLen);
    uint8_t   nextPacket(uint8_t streamWanted);
    uint8_t   skipPacket(void);
    
    uint32_t  getPos(void);
    uint32_t  getPayloadLen(void);
#ifdef ASF_INLINE
    #include "ADM_asfIo.h"
#else    
    uint64_t  read64(void);
    uint32_t  read32(void);
    uint32_t  read16(void);
    uint8_t   read8(void);
#endif    
    uint8_t   read(uint8_t *where, uint32_t how);
    uint8_t   purge(void);
    uint8_t   packTo(uint8_t *buffer,uint32_t *len);
};

#endif

