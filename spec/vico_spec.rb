require 'spec_helper'
require 'vico'

describe Vico do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end

describe World do
  it 'has a name' do
    expect(described_class.new(name: 'hello world').name).to eq('hello world')
  end
end

describe Zone do
  it 'has an address' do
    expect(described_class.new(address: '1234 main st').address).to eq('1234 main st')
  end
end

describe Pawn do
  it 'has a name' do
    expect(described_class.new(name: 'bob').name).to eq('bob')
  end
end

describe WorldServer do
  subject(:world_server) do
  # before do
    # @world_server =
    WorldServer.new(world: world, port: 1234)
  end

  after do
    # binding.pry
    world_server.halt!
  end

  let(:world) { World.new(name: 'boodrox') }

  it 'has a world' do
    expect(world_server.world).to eq(world)
  end

  it 'has a port' do
    expect(world_server.port).to eq(1234)
  end
end

describe ZoneServer do
  subject(:zone_server) do
    ZoneServer.new(address: address)
  end

  let(:address) { '1234 main st' }

  it 'has a world' do
    expect(zone_server.address).to eq(address)
  end
end

describe Client do
  it 'points to localhost by default' do
    expect(described_class.new.host).to eq('localhost')
  end
end

describe Text do
  it 'connects to local server by default' do
    expect(described_class.new.host).to eq('localhost')
  end
end

describe Screen do
  it 'connects to local server' do
    expect(described_class.new.host).to eq('localhost')
  end

  xit 'should display a map' do
  end
end
