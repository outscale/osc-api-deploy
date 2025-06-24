#!/bin/env ruby

require 'psych'
require 'optparse'

options = {}
OptionParser.new do |opt| 
  opt.on('--nodatetime') { || options[:nodatetime] = true }
  opt.on('--nodate') { || options[:nodate] = true }
  opt.on('--nooneof') { || options[:nooneof] = true }
  opt.on('--noproperties-array') { || options[:nopropertiesarray] = true }
  opt.on('--input FILE') { |o| options[:input] = o }
end.parse!

api = Psych.load_file options[:input], permitted_classes: [Time]

def patch_no_oneof(arg_info)
  # Remove all oneOf by substituing for the first element in the array
  if arg_info.key?("oneOf") then
    arg_info["oneOf"][0].each do |key, val|
      arg_info[key] = val
    end
    arg_info.delete("oneOf")
  elsif arg_info.key?("items") and arg_info["items"].key?("oneOf") then
    arg_info["items"] = arg_info["items"]["oneOf"][0]
    arg_info["items"].delete("oneOf")
  end

  return arg_info
end

def patch_no_datetime(arg_info)
  # Remove date-time to make it fallback to string
  if arg_info["format"] == "date-time" then
    arg_info.delete("format")
  elsif arg_info.key?("items") and arg_info["items"]["format"] == "date-time" then
    arg_info["items"].delete("format")
  end

  return arg_info
end

def patch_no_date(arg_info)
  # Remove date to make it fallback to string
  if arg_info["format"] == "date" then
    arg_info.delete("format")
  elsif arg_info.key?("items") and arg_info["items"]["format"] == "date" then
    arg_info["items"].delete("format")
  end

  return arg_info
end

def patch_no_poperties_array(prop_info)
  if prop_info["type"] == "array" && prop_info.key?("items")
    items = prop_info["items"]
    if items.key?("$ref")
      if items["$ref"] =~ %r{#/components/schemas/(\w+)}
        ref_name = $1
        schema = $no_properties.find { |s| s[:name] == ref_name }
        if schema
          items.delete("$ref")
          items["type"] = schema[:type]
        end
      end
    end
  end

  return prop_info
end

if options.key?(:nopropertiesarray) then
  # Index properties for later use by patch_no_poperties_array 
  $no_properties = []
  api["components"]["schemas"].each do |call_name, call|
    unless call.key?("properties")
      $no_properties << { name: call_name, type: call["type"] }
    end
  end
end

api["components"]["schemas"].each do |call_name, call|
  if call.key?("properties") then
    call["properties"].each do |arg_name, arg_info|
      if options.key?(:nooneof) then
        arg_info = patch_no_oneof(arg_info)
      end
      
      if options.key?(:nodatetime) then
        arg_info = patch_no_datetime(arg_info)
      end
      
      if options.key?(:nodate) then
        arg_info = patch_no_date(arg_info)
      end

      if options.key?(:nopropertiesarray) then
        arg_info = patch_no_poperties_array(arg_info)
      end
    end
  end
end

puts Psych.dump(api)
