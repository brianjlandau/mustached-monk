require File.join(File.dirname(__FILE__), "/../../spec_helper")

module ActiveSupport
  module Cache
    describe "ActiveSupport::Cache::RedisStore" do
      before(:each) do
        @store  = ActiveSupport::Cache::RedisStore.new
        @dstore = ActiveSupport::Cache::RedisStore.new "localhost:6380/1", "localhost:6381/1"
        @rabbit = OpenStruct.new :name => "bunny"
        @white_rabbit = OpenStruct.new :color => "white"
        with_store_management do |store|
          store.write  "rabbit", @rabbit
          store.delete "counter"
          store.delete "rub-a-dub"
        end
      end

      it "should accept connection params" do
        redis = instantiate_store
        redis.host.should == "127.0.0.1"
        redis.port.should == 6379
        redis.db.should == 0

        redis = instantiate_store "localhost"
        redis.host.should == "localhost"
        
        redis = instantiate_store "localhost:6380"
        redis.host.should == "localhost"
        redis.port.should == 6380

        redis = instantiate_store "localhost:6380/13"
        redis.host.should == "localhost"
        redis.port.should == 6380
        redis.db.should == 13
      end

      it "should instantiate a ring" do
        store = instantiate_store
        store.should be_kind_of(MarshaledRedis)
        store = instantiate_store ["localhost:6379/0", "localhost:6379/1"]
        store.should be_kind_of(DistributedMarshaledRedis)
      end

      it "should read the data" do
        with_store_management do |store|
          store.read("rabbit").should === @rabbit
        end
      end

      it "should write the data" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit
          store.read("rabbit").should === @white_rabbit
        end
      end

      it "should write the data with expiration time" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :expires_in => 1.second
          store.read("rabbit").should === @white_rabbit ; sleep 2
          store.read("rabbit").should be_nil
        end
      end

      it "should not write data if :unless_exist option is true" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :unless_exist => true
          store.read("rabbit").should === @rabbit
        end
      end

      it "should read raw data" do
        with_store_management do |store|
          store.read("rabbit", :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\nbunny"
        end
      end

      it "should write raw data" do
        with_store_management do |store|
          store.write "rabbit", @white_rabbit, :raw => true
          store.read("rabbit", :raw => true).should == %(#<OpenStruct color="white">)
        end
      end

      it "should delete data" do
        with_store_management do |store|
          store.delete "rabbit"
          store.read("rabbit").should be_nil
        end
      end

      it "should delete matched data" do
        with_store_management do |store|
          store.delete_matched "rabb*"
          store.read("rabbit").should be_nil
        end
      end

      it "should verify existence of an object in the store" do
        with_store_management do |store|
          store.exist?("rabbit").should be_true
          store.exist?("rab-a-dub").should be_false
        end
      end

      it "should increment a key" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          store.read("counter", :raw => true).to_i.should == 3
        end
      end

      it "should decrement a key" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          2.times { store.decrement "counter" }
          store.read("counter", :raw => true).to_i.should == 1
        end
      end

      it "should increment a key by given value" do
        with_store_management do |store|
          store.increment "counter", 3
          store.read("counter", :raw => true).to_i.should == 3
        end
      end

      it "should decrement a key by given value" do
        with_store_management do |store|
          3.times { store.increment "counter" }
          store.decrement "counter", 2
          store.read("counter", :raw => true).to_i.should == 1
        end
      end

      it "should clear the store" do
        with_store_management do |store|
          store.clear
          store.instance_variable_get(:@data).keys("*").should be_empty
        end
      end

      it "should return store stats" do
        with_store_management do |store|
          store.stats.should_not be_empty
        end
      end

      it "should fetch data" do
        with_store_management do |store|
          store.fetch("rabbit").should == @rabbit
          store.fetch("rub-a-dub").should be_nil
          store.fetch("rub-a-dub") { "Flora de Cana" }
          store.fetch("rub-a-dub").should === "Flora de Cana"
          store.fetch("rabbit", :force => true).should be_nil # force cache miss
          store.fetch("rabbit", :force => true, :expires_in => 1.second) { @white_rabbit }
          store.fetch("rabbit").should === @white_rabbit ; sleep 2
          store.fetch("rabbit").should be_nil
        end
      end
      
      private
        def instantiate_store(addresses = nil)
          ActiveSupport::Cache::RedisStore.new(addresses).instance_variable_get(:@data)
        end

        def with_store_management
          yield @store
          yield @dstore
        end
    end
  end
end
