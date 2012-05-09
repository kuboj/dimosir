require "spec_helper"

describe Dimosir::ThreadPool do

  describe "#new" do

    it "takes two parameters" do
      logger = double("logger")
      size = 10

      tp = Dimosir::ThreadPool.new(logger, size)
      tp.should be_instance_of Dimosir::ThreadPool
    end

  end

end