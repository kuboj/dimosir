require "spec_helper"

describe Dimosir::Check::Ping do

  describe "#new" do

    it "creates new Ping check via inherited method" do
      p = Dimosir::Check::Ping.new("test", "localhost", {})
      p.should be_instance_of Dimosir::Check::Ping
    end

  end

  describe "#perform_check" do

    it "pings localhost with default values" do
      p = Dimosir::Check::Ping.new("test", "localhost", {})
      p.perform_check[1].should eql 0
    end

    it "pings google.com 3 times" do
      p = Dimosir::Check::Ping.new("pinging google", "google.com", {"-c" => 3})
      p.perform_check[1].should eql 0
    end

  end

end