#!/usr/bin/python

def do_flip_x(width, height, data):
  import bytebuffer
  ibs = bytebuffer.ReadBuffer(data)
  obs = bytebuffer.WriteBuffer()
  for y in range(height):
    l = []
    # read one scanline
    for x in range(width):
      v = (ibs.readF32(), ibs.readF32(), ibs.readF32())
      l.append(v)
    # write the inverted scanline
    for x in range(width):
      obs.writeF32(l[width-x-1][0])
      obs.writeF32(l[width-x-1][1])
      obs.writeF32(l[width-x-1][2])
  return obs.get()

def do_flip_y(width, height, data):
  import bytebuffer
  ibs = bytebuffer.ReadBuffer(data)
  obs = bytebuffer.WriteBuffer()
  scanlines = []
  for y in range(height):
    scanline = []
    # read one scanline
    for x in range(width):
      v = (ibs.readF32(), ibs.readF32(), ibs.readF32())
      scanline.append(v)
    scanlines.append(scanline)
  for y in range(height):
    # write the inverted scanlines
    scanline = scanlines[height-y-1]
    for x in range(width):
      obs.writeF32(scanline[x][0])
      obs.writeF32(scanline[x][1])
      obs.writeF32(scanline[x][2])
  return obs.get()

def save_pfm(image, name, width, height, flip_x=False, flip_y=False):
  print("  writing %s..."%name)
  f = open(name, "wb") 
  f.write("PF\x0a%u %u\x0a%f\x0a"%(width, height, -1))
  data = image.get()
  if flip_x:
    data = do_flip_x(width, height, data)
  if flip_y:
    data = do_flip_y(width, height, data)
  f.write(data)
  f.close()

def main():
  import sys
  print("Parsing %s"%sys.argv[1])
  f = open(sys.argv[1], "rb")
  data = f.read()
  f.close()
  import bytebuffer
  ibs = bytebuffer.ReadBuffer(data)
  pf_header = ibs.readLine()
  if pf_header != "PF":
    print("Not a color pfm!")
    return
  resolution = ibs.readLine().split(" ")
  width = int(resolution[0])
  height = int(resolution[1])
  scale = float(ibs.readLine())
  if scale < 0:
    ibs.setEndian("<")
    scale = -scale
  else:
    ibs.setEndian(">")
  image_width = width/3
  image_height = height/4
  image = [bytebuffer.WriteBuffer() for x in range(12)]
  for y in range(height):
    for x in range(width):
      ix = x/image_width
      iy = y/image_height
      image_idx = ix + iy*3
      for c in range(3):
        image[image_idx].writeF32(ibs.readF32())
  print("Writing images...")
#  save_pfm(image[ 4], "rnl_ny.pfm", image_width, image_height, flip_x=False, flip_y=False)
#  save_pfm(image[ 1], "rnl_pz.pfm", image_width, image_height, flip_x=False, flip_y=False)
#  save_pfm(image[ 8], "rnl_px.pfm", image_width, image_height, flip_x=True, flip_y=True)
#  save_pfm(image[ 6], "rnl_nx.pfm", image_width, image_height, flip_x=True, flip_y=True)
#  save_pfm(image[ 7], "rnl_nz.pfm", image_width, image_height, flip_x=True, flip_y=True)
  save_pfm(image[10], "rnl_py.pfm", image_width, image_height, flip_x=False, flip_y=False)
  

if __name__ == "__main__":
  main()
