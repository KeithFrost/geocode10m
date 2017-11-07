#! /usr/bin/env ruby


class Base32
  CHARS = '0123456789abcdefghjkmnpqrstvwxyz'

  def self.make_map
    map = {}
    i = 0
    CHARS.split('').each do |c|
      map[c] = i
      i += 1
    end
    map
  end

  MAP = self.make_map

  def self.encode(num, pad=1)
    fail 'no negative numbers' if num < 0
    str = ''
    until num.zero?
      digit = num & 31
      num = num >> 5
      str[0,0] = CHARS[digit]
    end
    if str.size < pad
      str[0,0] = CHARS[0] * (pad - str.size)
    end
    str
  end

  def self.decode(str)
    str = str.downcase
    num = 0
    str.split('').each do |c|
      num = (num << 5) + MAP[c]
    end
    num
  end
end

class GeoCode
  PI = Math.acos(-1.0)

  def self.checksum(s)
    c0 = 15
    c1 = 0
    s.split('').each do |d|
      c1 += c0
      c0 += Base32::MAP[d]
      c0 = c0 & 31
    end
    c1 = c1 & 31
    Base32.encode(c0 * 32 + c1, 2)
  end

  def self.zip_bits(x, y)
    r = 0
    i = 0
    while (x >= (b = (1 << i)) || y >= b)
      r |= ((x & b) << (i + 1)) | ((y & b) << i)
      i += 1
    end
    r
  end

  def self.unzip_bits(r)
    x = 0
    y = 0
    i = 0
    while (r >= (b = (1 << i)))
      sh = i >> 1
      x |= (r & (b << 1)) >> (sh + 1)
      y |= (r & b) >> sh
      i += 2
    end
    [x, y]
  end

  def self.encode(latitude, longitude)
    lat = ((latitude + 90.0) * 10000 + 0.5).to_i
    lon = ((longitude + 180.0) * 10000 * Math.cos(PI * latitude / 180.0) + 0.5).to_i
    bcode = Base32.encode(self.zip_bits(lat, lon), 9)
    cs = self.checksum(bcode)
    "#{bcode[0..-5]}-#{bcode[-4..-1]}-#{cs}"
  end

  def self.decode(code)
    (hib_s, lob_s, cs) = code.split('-')
    bcode = hib_s + lob_s
    raise 'invalid code' unless self.checksum(bcode) == cs
    (lat, lon) = self.unzip_bits(Base32.decode(bcode))
    latitude = (lat * 1e-4) - 90.0
    longitude = 180.0 + (lon * 1e-4 / Math.cos(PI * latitude / 180.0))
    longitude -= 360.0 if longitude > 180.0
    [latitude, longitude]
  end
end

if __FILE__ == $0
  code = ARGV[0]
  if /\A[0-9A-Za-z]{5}[-][0-9A-Za-z]{4}[-][0-9A-Za-z]{2}\z/ =~ code
    puts '%0.4f,%0.4f' % GeoCode.decode(code)
  elsif /\A-?\d+(\.\d*)?,-?\d+(\.\d*)?\z/ =~ code
    (lat, lon) = code.split(',')
    puts GeoCode.encode(lat.to_f, lon.to_f)
  else
    fail 'format error'
  end
end
