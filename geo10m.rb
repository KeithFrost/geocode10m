#! /usr/bin/env ruby


class GeoCode
  PI = Math.acos(-1.0)

  def self.checksum(lat_s, lon_s)
    c0 = 0
    c1 = 0
    lat_s.split('').each do |d|
      c1 += c0
      c0 += d.to_i(36)
      c0 = c0 % 31
    end
    c0 += 30
    lon_s.split('').each do |d|
      c1 += c0
      c0 += d.to_i(36)
      c0 = c0 % 31
    end
    c1 = c1 % 29
    c0.to_s(31) + c1.to_s(31)
  end


  def self.encode(latitude, longitude)
    lat = ((latitude + 90.0) * 10000).to_i
    lon = ((longitude + 180.0) * 10000 * Math.cos(PI * latitude / 180.0)).to_i
    lon_s = lon.to_s(36)
    lat_s = lat.to_s(36)
    cs = self.checksum(lat_s, lon_s)
    "#{lat_s}-#{cs}-#{lon_s}"
  end

  def self.decode(code)
    (lat_s, cs, lon_s) = code.split('-')
    raise 'invalid code' unless self.checksum(lat_s, lon_s) == cs
    lat = lat_s.to_i(36)
    latitude = (lat * 1e-4) - 90.0
    lon = lon_s.to_i(36)
    longitude = 180.0 + (lon * 1e-4 / Math.cos(PI * latitude / 180.0))
    longitude -= 360.0 if longitude > 180.0
    [latitude, longitude]
  end
end

if __FILE__ == $0
  code = ARGV[0]
  if /\A[0-9A-Za-z]+[-][0-9A-Za-z]{2}[-][0-9A-Za-z]+\z/ =~ code
    puts '%0.4f,%0.4f' % GeoCode.decode(code)
  elsif /\A-?\d+(\.\d*)?,-?\d+(\.\d*)?\z/ =~ code
    (lat, lon) = code.split(',')
    puts GeoCode.encode(lat.to_f, lon.to_f)
  else
    raise 'format error'
  end
end
