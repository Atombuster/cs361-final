#!/usr/bin/env ruby
require 'json'

class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end
    # set segments to segment_objects
    @segments = segment_objects
  end

  def get_track_json()
    if @name != nil
    name = '"properties": {"title":  "' + @name + '"},'
    end

    json = '{"type": "Feature",' + name + '"geometry": {"type": "MultiLineString","coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        json += ","
      end
      json += '['
      # Loop through all the coordinates in the segment
      temporary_string_json = ''
      s.coordinates.each do |c|
        if temporary_string_json != ''
          temporary_string_json += ','
        end
        # Add the coordinate
        temporary_string_json += '[' + "#{c.longitude},#{c.latitiude}"
        if c.elevation != nil
          temporary_string_json += ",#{c.elevation}"
        end
        temporary_string_json += ']'
      end
      json+=temporary_string_json
      json+=']'
    end
    json + ']}}'
  end
end





  
class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point

  attr_reader :latitiude, :longitude, :elevation

  def initialize(longitude, latitiude, elevation=nil)
    @longitude = longitude
    @latitiude = latitiude
    @elevation = elevation
  end
end





class Waypoint

attr_reader :latitiude, :longitude, :elevation, :name, :type

  def initialize(longitude, latitiude, elevation=nil, name=nil, type=nil)
    @latitiude = latitiude
    @longitude = longitude
    @elevation = elevation
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    json = '{"type": "Feature","geometry": {"type": "Point","coordinates": ' + "[#{@longitude},#{@latitiude}"
    if elevation != nil
      json += ",#{@elevation}"
    end
    json += ']},'
    if name != nil or type != nil
      json += '"properties": {'
      if name != nil
        json += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          json += ','
        end
        json += '"icon": "' + @type + '"'  # type is the icon
      end
      json += '}'
    end
    json += "}"
    return json
  end


end

class World
def initialize(name, things)
  @name = name
  @features = things
end
  def add_feature(f)
    @features.append(f)
  end

  def to_geojson(indent=0)#ruby can do json
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
        if f.class == Track #did in exersion 9
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
      end
    end
    s + "]}"
  end
end

def main()
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

