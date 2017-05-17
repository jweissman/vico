require 'spec_helper'
require 'vico'

describe Vico do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end

describe WorldMap do
  it 'has width and height' do
    expect(described_class.new(width: 10, height: 15).height).to eq(15)
    expect(described_class.new(width: 10, height: 15).width).to eq(10)
    expect(described_class.new(width: 10, height: 15).field.length).to eq(15)
    expect(described_class.new(width: 10, height: 15).field[0].length).to eq(10)
    expect(described_class.new(width: 10, height: 15).area).to eq(150)
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
    expect(described_class.new(name: 'bob', x: nil, y: nil).name).to eq('bob')
  end

  it 'has a position' do
    expect(described_class.new(name: '', x: 3, y: 4).x).to eq(3)
    expect(described_class.new(name: '', x: 3, y: 4).y).to eq(4)
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
