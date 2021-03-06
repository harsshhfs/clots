module Clot
  module TagHelper
    def split_params(params)
      params.split(",").map(&:strip)
    end

    def resolve_value(value, context)
      case value
        when Liquid::Drop then
          value.source
        when /^([\[])(.*)([\]])$/ then
          array = $2.split " "; array.map { |item| resolve_value item, context }
        when /^"(\{.*\})"$/ then
          eval($1) # hash from string
        when /^(["'])(.*)\1$/ then
          $2
        when /^(\d+[\.]\d+)$/ then
          $1.to_f
        when /^(\d+)$/ then
          value.to_i
        when /^true$/ then
          true
        when /^false$/ then
          false
        when /^nil$/ then
          nil
        when /^(.+)_path$/ then
          "/#{$1}"
        else
          result = context[value]
          result.is_a?(Liquid::Drop) ? result.source : result
      end
    end

  end
end
