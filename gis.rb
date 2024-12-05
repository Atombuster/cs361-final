#!/usr/bin/env ruby
require 'json'



class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |segment|
      segment_objects.append(TrackSegment.new(segment))
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
    @segments.each_with_index do |segment, index|
      if index > 0
        json += ","
      end
      json += '['
      # Loop through all the coordinates in the segment
      temporary_string_json = ''
      segment.coordinates.each do |coordinate|
        if temporary_string_json != ''
          temporary_string_json += ','
        end
        # Add the coordinate
        temporary_string_json += '[' + "#{coordinate.longitude},#{coordinate.latitiude}"
        if coordinate.elevation != nil
          temporary_string_json += ",#{coordinate.elevation}"
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
  def add_feature(feature)
    @features.append(feature)
  end

  def to_geojson(indent=0)#ruby can do json
    # Write stuff
    json = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature,i|
      if i != 0
        json +=","
      end
        if feature.class == Track #did in exersion 9
            json += feature.get_track_json
        elsif feature.class == Waypoint
            json += feature.get_waypoint_json
      end
    end
    json + "]}"
  end
end

def main()
  waypoint = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  waypoint2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  temporary_string1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  temporary_string2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  temporary_string3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track = Track.new([temporary_string1, temporary_string2], "track 1")
  track2 = Track.new([temporary_string3], "track 2")

  world = World.new("My Data", [waypoint, waypoint2, track, track2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

