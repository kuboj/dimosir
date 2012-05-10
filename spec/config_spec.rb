require "spec_helper"

describe Dimosir::Config do

  before(:all) do
    $testing_file = "testing_config.yaml"
    $config = {
      "database" => {
        "host" => "localhost",
        "port" => 11111,
        "user" => "test",
        "password" => "test",
        "db_name" => "test"
      },
      "peer" => {
        "ip" => "127.0.0.1",
        "port" => 10000
      },
      "application" => {
        "log_file" => "kvik.log",
        "log_level" => 1
      },
    }
  end

  before(:each) do
    File.open($testing_file, "w") { |f| f.write($config.to_yaml) }
  end

  after(:each) do
    File.delete($testing_file) if File.exists?($testing_file)
  end

  describe "::parse_file" do

    it "raises error if config file doesn't exist" do
      lambda { Dimosir::Config.parse_file("nonexistingfile") }.should raise_exception LoadError
    end

    it "reads config file correctly" do
      options = Dimosir::Config.parse_file($testing_file)
      options.has_key?("database").should be_true
      options.has_key?("peer").should be_true
      options.has_key?("application").should be_true
      options["application"]["log_level"].should eql 1
    end

  end

end