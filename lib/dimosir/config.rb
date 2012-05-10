require "yaml"

module Dimosir

  class Config

    def self.parse_file(file)
      # TODO: config validity check. if field missing -> inform in exception
      raise LoadError, "Config file #{file} doesn't exist!" if not File.exists?(file)
      YAML.load_file(file)
    end

  end

end