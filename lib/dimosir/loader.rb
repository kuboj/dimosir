module Dimosir

  class Loader

    def self.load_check(check_name)
      check_file = "#{File.expand_path(File.dirname(__FILE__))}/check/#{check_name}.rb"
      raise LoadError, "Could not load '#{check_name}' - check file missing" unless File.exists?(check_file)
      require_relative "check/#{check_name}"
      raise LoadError, "Could not load '#{check_name}' - check class missing" unless self.check_class_exists(check_name)
    end

    def self.check_class_exists(check_name)
      return Dimosir::Check.const_defined?("#{check_name.capitalize}")
    end

  end

end