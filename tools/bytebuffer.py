from struct import *
import string
from binascii import b2a_hex

FILTER=''.join([(len(repr(chr(x)))==3) and chr(x) or '.' for x in range(256)])

def dump(src, length=16):
    N=0; result=''
    while src:
        s,src = src[:length],src[length:]
        hexa = ' '.join(["%02X"%ord(x) for x in s])
        s = s.translate(FILTER)
        result += "%04X   %-*s   %s\n" % (N, length*3, hexa, s)
        N+=length
    return result

class WriteBuffer:
    def __init__(self):
        self.data = []

    def write(self, d):
        self.data.append(d)

    def writeU8(self, v):
        self.data.append(pack('<B', v))

    def writeU16(self, v):
        self.data.append(pack('<H', v))

    def writeU32(self, v):
        self.data.append(pack('<I', v))

    def writeI8(self, v):
        self.data.append(pack('<b', v))

    def writeI16(self, v):
        self.data.append(pack('<h', v))

    def writeI32(self, v):
        self.data.append(pack('<i', v))

    def writeF32(self, v):
        self.data.append(pack('<f', v))

    def writeStr8(self, s):
        l = min(len(s), 0xff)
        self.writeU8(l)
        self.data.append(s[:l])

    def writeStr16(self, s):
        l = min(len(s), 0xffff)
        self.writeU16(l)
        self.data.append(s[:l])

    def writeStr32(self, s):
        l = min(len(s), 0xffffffff)
        self.writeU32(l)
        self.data.append(s[:l])

    def get(self):
        return string.join(self.data, '')

    def length(self):
        return len(self.get())

    def dump(self):
        data = self.get()
        return "WriteBuffer of length %i with data\n%s"%(len(data), dump(data))

# ReadBuffer example usage:
#        ibs = ReadBuffer(obs.get())
#        print(ibs.readU8())
#        print(ibs.readU8())
#        print(ibs.readU32())
#        print(ibs.readStr8())
#        print(ibs.readU8())
class ReadBuffer:
    def __init__(self, data):
        self.data = data
        self.offset = 0
        self.endianess = "<"

    def setEndian(self, endian):
        self.endianess = endian

    def hasMore(self):
        if self.offset<len(self.data):
            return True
        else:
            return False

    def advance(self, l):
      self.offset += l

    def getRemainingData(self):
      return self.data[self.offset:]

    def readData(self, length):
        v = self.data[self.offset:self.offset+length]
        self.offset += length
        return v

    def read(self, fmt):
        v = unpack_from( self.endianess+fmt, self.data, self.offset)
        self.offset += calcsize(self.endianess+fmt)
        return v

    def readU8(self):
        return self.read('B')[0]

    def readU16(self):
        return self.read('H')[0]

    def readU32(self):
        return self.read('I')[0]

    def readI8(self):
        return self.read('b')[0]

    def readI16(self):
        return self.read('h')[0]

    def readI32(self):
        return self.read('i')[0]

    def readF32(self):
        return self.read('f')[0]

    def readData(self, l):
        s = self.data[self.offset:self.offset+l]
        self.offset += l
        return s

    def readLine(self):
        n = self.readU8()
        s = ""
        while n != 0x0a and self.getRemainingData() > 0:
          s += chr(n)
          n = self.readU8()
        return s

    def readStr8(self):
        l = self.readU8()
        s = self.data[self.offset:self.offset+l]
        self.offset += l
        return s

    def readStr16(self):
        l = self.readU16()
        s = self.data[self.offset:self.offset+l]
        self.offset += l
        return s

    def readStr32(self):
        l = self.readU32()
        s = self.data[self.offset:self.offset+l]
        self.offset += l
        return s

    def length(self):
        return len(self.data)

    def dump(self):
        return "ReadBuffer of length %i at offset %i with data\n%s"%(len(self.data),
                self.offset, dump(self.data))
