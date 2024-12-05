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


    coordinates_input = []
    @segments.each do |segment| 
      coordinates_input_sub = []
      segment.coordinates.each do |coordinate| 
        current_array = [coordinate.longitude, coordinate.latitude] 
        current_array << coordinate.elevation if coordinate.elevation 
        coordinates_input_sub << current_array
      end
      coordinates_input << coordinates_input_sub
    end




    track_json = {
      type: 'Feature',
      properties: {
      title: @name
      },
      geometry: {
        type: 'MultiLineString',
        coordinates: coordinates_input
      }
    }

    JSON.generate(track_json)

  end

end
  
class TrackSegment

  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

end

class Point

  attr_reader :latitude, :longitude, :elevation

  def initialize(longitude, latitude, elevation=nil)
    @longitude = longitude
    @latitude = latitude
    @elevation = elevation
  end

end





class Waypoint

attr_reader :latitude, :longitude, :elevation, :name, :type

  def initialize(longitude, latitude, elevation=nil, name=nil, type=nil)
    @latitude = latitude
    @longitude = longitude
    @elevation = elevation
    @name = name
    @type = type
  end

  def create_array(input1, input2, input3 = nil) 
    [input1, input2, input3].compact 
  end

  def get_waypoint_json(indent = 0)
    longitude_latitude_elevation = self.create_array(longitude, latitude, elevation)
    
    json = {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: longitude_latitude_elevation
      },
      properties: {}
    }
    json[:properties][:title] = @name if @name
    json[:properties][:icon] = @type if @type
    JSON.pretty_generate(json, indent: ' ' * indent)
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


  def to_geojson(indent=0)

    feature_get_json = []
    current_array = []
    @features.each_with_index do |feature,i|
      if i != 0
        current_array = []
      end
      current_array = feature.is_a?(Track) ? JSON.parse(feature.get_track_json) : JSON.parse(feature.get_waypoint_json(indent))
      feature_get_json << current_array
    end


    json = {
      type: "FeatureCollection",
    features: feature_get_json
  }
  JSON.generate(json, indent: ' ' * indent)
    
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

