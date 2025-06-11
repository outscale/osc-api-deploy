#!/bin/ruby

# OpenAPI format can reference schemas that have no properties.
#
# Array items that reference these schemas can cause issues for the C generator.

require 'psych'

api = Psych.load_file(ARGV[0])

no_properties = []
api["components"]["schemas"].each do |call_name, call|
  unless call.key?("properties")
    no_properties << { name: call_name, type: call["type"] }
  end
end

api["components"]["schemas"].each do |schema_name, schema|
  if schema.key?("properties") then
    schema["properties"].each do |prop_name, prop_info|
      if prop_info["type"] == "array" && prop_info.key?("items")
        items = prop_info["items"]
        if items.key?("$ref")
          if items["$ref"] =~ %r{#/components/schemas/(\w+)}
            ref_name = $1
            schema = no_properties.find { |s| s[:name] == ref_name }
            if schema
              items.delete("$ref")
              items["type"] = schema[:type]
            end
          end
        end
      end
    end
  end
end

puts Psych.dump(api)
