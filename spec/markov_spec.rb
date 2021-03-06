require File.dirname(__FILE__) + '/spec_helper.rb'

describe Markov do
  before :each do
    @markov = Markov.new
  end
  
  describe 'when initialized' do
    before :each do
      Markov.instance_eval do
        public :data
      end
    end
    
    it 'should have empty data' do
      @markov.data.should == {}
    end
  end
  
  it 'should reset itself' do
    @markov.should respond_to(:reset)
  end
  
  describe 'when resetting itself' do
    before :each do
      Markov.instance_eval do
        public :data, :data=
      end
    end
    
    it 'should empty its data' do
      @markov.data = { 'a' => [ 'b' ] }
      @markov.reset
      @markov.data.should == {}
    end
  end
  
  it 'should allow adding' do
    @markov.should respond_to(:add)
  end
  
  describe 'adding' do
    it 'should accept an argument' do
      lambda { @markov.add('a') }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept multiple arguments' do
      lambda { @markov.add('a', 'b', 'c', 'd', 'e', 'f') }.should_not raise_error(ArgumentError)
    end
    
    it 'should require at least one argument' do
      lambda { @markov.add }.should raise_error(ArgumentError)
    end
  end
  
  describe 'checking data after adding' do
    before :each do
      Markov.instance_eval do
        public :data, :data=
      end
    end
    
    describe 'a single argument' do
      it 'should add the argument when its data is empty' do
        @markov.reset
        @markov.add('a')
        @markov.data.should == { 'a' => [] }
      end
      
      it 'should add the argument to already-present data' do
        @markov.data = { 'a' => [ 'b' ] }
        @markov.add('e')
        @markov.data.should == { 'a' => [ 'b' ], 'e' => [] }
      end
      
      it 'should add the argument and retain already-present data' do
        @markov.data = { 'a' => [ 'b' ] }
        @markov.add('a')
        @markov.data.should == { 'a' => [ 'b' ] }
      end
    end
    
    describe 'a pair of arguments' do
      it 'should add the arguments when its data is empty' do
        @markov.reset
        @markov.add('a', 'b')
        @markov.data.should == { 'a' => [ 'b' ], 'b' => [] }
      end
      
      it 'should add the arguments to already-present data' do
        @markov.data = { 'a' => [ 'b' ] }
        @markov.add('e', 'f')
        @markov.data.should == { 'a' => [ 'b' ], 'e' => [ 'f' ], 'f' => [] }
      end
      
      it 'should add the arguments and retain already-present data' do
        @markov.data = { 'a' => [ 'b' ] }
        @markov.add('a', 'f')
        @markov.data.should == { 'a' => [ 'b', 'f' ], 'f' => [] }
      end
      
      it 'should add the arguments to already-present data about the same linkage' do
        @markov.data = { 'a' => [ 'b' ] }
        @markov.add('a', 'b')
        @markov.data.should == { 'a' => [ 'b', 'b' ], 'b' => [] }
      end
    end
    
    describe 'many arguments' do
      it 'should add the arguments when its data is empty' do
        @markov.reset
        @markov.add('a', 'b', 'c', 'd', 'e')
        @markov.data.should == { 'a' => [ 'b' ], 'b' => [ 'c' ], 'c' => [ 'd' ], 'd' => [ 'e' ], 'e' => [] }
      end
      
      it 'should add the arguments to already-present data' do
        @markov.data = { 'a' => [ 'b' ] }
        @markov.add('e', 'f', 'g', 'h', 'i')
        @markov.data.should == { 'a' => [ 'b' ], 'e' => [ 'f' ], 'f' => [ 'g' ], 'g' => [ 'h' ], 'h' => [ 'i' ], 'i' => [] }
      end
      
      it 'should add the arguments and retain already-present data' do
        @markov.data = { 'a' => [ 'b' ], 'f' => [ 'q' ] }
        @markov.add('a', 'f', 'g', 'h', 'i')
        @markov.data.should == { 'a' => [ 'b', 'f' ], 'f' => [ 'q', 'g' ], 'g' => [ 'h' ], 'h' => [ 'i' ], 'i' => [] }
      end
      
      it 'should add the arguments to already-present data about the same linkage' do
        @markov.data = { 'a' => [ 'b' ], 'f' => [ 'g' ] }
        @markov.add('a', 'b', 'e', 'f', 'g', 'h', 'i')
        @markov.data.should == { 'a' => [ 'b', 'b' ], 'b' => [ 'e' ], 'e' => [ 'f' ], 'f' => [ 'g', 'g' ], 'g' => [ 'h' ], 'h' => [ 'i' ], 'i' => [] }
      end
    end
  end
  
  it 'should generate' do
    @markov.should respond_to(:generate)
  end
  
  describe 'generating' do
    before :each do
      @data = { 'a' => ['b', 'c'], 'b' => ['c'], 'c' => ['d'], 'd' => ['e'], 'e' => [] }
      @markov.stubs(:data).returns(@data)
      @keys = @data.keys
      @data.stubs(:keys).returns(@keys)
    end
    
    it 'should accept an argument' do
      lambda { @markov.generate(5) }.should_not raise_error(ArgumentError)
    end
    
    it 'should not require an argument' do
      lambda { @markov.generate }.should_not raise_error(ArgumentError)
    end
    
    it 'should get its data' do
      @markov.expects(:data).returns(@data)
      @markov.generate
    end
    
    it "should get its data's keys" do
      @data.expects(:keys).returns(@keys)
      @markov.generate
    end
    
    it 'should get a random key' do
      @keys.expects(:random).returns(@keys.first)
      @markov.generate
    end
    
    it 'should access the data for the returned key' do
      key = @keys.first
      @keys.stubs(:random).returns(key)
      @data.expects(:[]).with(key).returns([])
      @markov.generate
    end
    
    it 'should get a random element from the data for the returned key' do
      key = @keys.first
      key_data = @data[key]
      @keys.stubs(:random).returns(key)
      @data.stubs(:[]).returns([])
      @data.stubs(:[]).with(key).returns(key_data)
      key_data.expects(:random).returns(key_data.first)
      @markov.generate
    end
    
    it 'should not get an element from the data for the returned key if that data is empty' do
      key = @keys.first
      key_data = []
      @keys.stubs(:random).returns(key)
      @data.stubs(:[]).with(key).returns(key_data)
      key_data.expects(:random).never
      @markov.generate
    end
    
    it 'should return the items' do
      key = @keys.first
      key_data = @data[key]
      @keys.stubs(:random).returns(key)
      @data.stubs(:[]).returns([])
      @data.stubs(:[]).with(key).returns(key_data)
      item = key_data.random
      key_data.stubs(:random).returns(item)
      @markov.generate.should == [key, item]
    end
    
    it 'should limit the returned items if given an argument' do
      @markov.generate(1).length.should == 1
    end
    
    it 'should return an empty array if there are no keys' do
      @data.stubs(:keys).returns([])
      @markov.generate.should == []
    end
  end
end
