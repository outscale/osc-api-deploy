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

api["components"]["schemas"].each do |call_name, call|
  #puts key
  call["properties"].each do |arg_name,arg_info|
    #print arg_name, ": ", arg_info.key?("oneOf"), "\n"
    if arg_info.key?("oneOf") then
      arg_info["oneOf"][0].each do |key, val|
        arg_info[key] = val
      end
      arg_info.delete("oneOf")
    end
  end
end

puts Psych.dump(api)
