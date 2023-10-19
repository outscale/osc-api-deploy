#!/bin/ruby

# OpenAPI format can use `oneOf` fields
# https://swagger.io/docs/specification/data-models/oneof-anyof-allof-not/#oneof
#
# `oneOf`usage are problematic for some SDK generators from openapi-generator project:
# https://openapi-generator.tech/docs/generators/
#
# Waiting for generators to manage `oneOf`, this quick and dirty patcher will remove them.

require 'psych'

api = Psych.load_file(ARGV[0])
old = Psych.load_file(ARGV[1])

old_schema = old["components"]["schemas"]

api["components"]["schemas"].each do |call_name, call|
  #puts key
  call["properties"].each do |arg_name,arg_info|
    #print arg_name, ": ", arg_info.key?("oneOf"), "\n"
    if arg_info.key?("oneOf") then
      arg_info["oneOf"][0].each do |key, val|
        arg_info[key] = val
      end
      arg_info.delete("oneOf")
    elsif arg_info.key?("items") and arg_info["items"].key?("oneOf") then
      arg_info["items"]["oneOf"][0].each do |key, val|
        arg_info["items"] = val
      end
      arg_info["items"].delete("oneOf")
    end
    if old_schema.key?(call_name) then
      old_arg_prop = old_schema[call_name]["properties"]
      if old_arg_prop.key?(arg_name) then
        if old_arg_prop[arg_name].key?("format") then
          arg_info["format"] = old_arg_prop[arg_name]["format"]
        elsif old_arg_prop[arg_name].key?("items") then
          arg_info["items"] = old_arg_prop[arg_name]["items"]
        end
      end
    end

  end
end

puts Psych.dump(api)
