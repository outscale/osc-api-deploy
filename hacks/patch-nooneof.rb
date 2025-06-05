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
  if call.key?("properties") then
    call["properties"].each do |arg_name,arg_info|
      if arg_info.key?("oneOf") then
        arg_info["oneOf"][0].each do |key, val|
          arg_info[key] = val
        end
        arg_info.delete("oneOf")
      elsif arg_info.key?("items") and arg_info["items"].key?("oneOf") then
        arg_info["items"] = arg_info["items"]["oneOf"][0]
        arg_info["items"].delete("oneOf")
      end
    end
  end
end

puts Psych.dump(api)
