require 'spec_helper'
require 'capybara/webkit/connection'

describe Capybara::Webkit::Connection do
  it "boots a server to talk to" do
    url = "http://#{@rack_server.host}:#{@rack_server.port}/"
    connection.puts "Visit"
    connection.puts 1
    connection.puts url.to_s.bytesize
    connection.print url
    connection.gets.should == "ok\n"
    connection.gets.should == "0\n"
    connection.puts "Body"
    connection.puts 0
    connection.gets.should == "ok\n"
    response_length = connection.gets.to_i
    response = connection.read(response_length)
    response.should include("Hey there")
  end

  it 'forwards stderr to the given IO object' do
    io = StringIO.new
    redirected_connection = Capybara::Webkit::Connection.new(:stderr => io)
    script = 'console.log("hello world")'
    redirected_connection.puts "EnableLogging"
    redirected_connection.puts 0
    redirected_connection.puts "Execute"
    redirected_connection.puts 1
    redirected_connection.puts script.to_s.bytesize
    redirected_connection.print script
    sleep(0.5)
    io.string.should =~ /hello world $/
  end

  it 'does not forward stderr to nil' do
    IO.should_not_receive(:copy_stream)
    Capybara::Webkit::Connection.new(:stderr => nil)
  end

  it 'prints a deprecation warning if the stdout option is used' do
    Capybara::Webkit::Connection.any_instance.should_receive(:warn)
    Capybara::Webkit::Connection.new(:stdout => nil)
  end

  it 'does not forward stdout to nil if the stdout option is used' do
    Capybara::Webkit::Connection.any_instance.stub(:warn)
    IO.should_not_receive(:copy_stream)
    Capybara::Webkit::Connection.new(:stdout => nil)
  end

  it "returns the server port" do
    connection.port.should be_between 0x400, 0xffff
  end

  it 'sets appropriate options on its socket' do
    socket = stub('socket')
    TCPSocket.stub(:open).and_return(socket)
    if defined?(Socket::TCP_NODELAY)
      socket.should_receive(:setsockopt).with(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
    else
      socket.should_not_receive(:setsockopt)
    end
    Capybara::Webkit::Connection.new
  end

  it "chooses a new port number for a new connection" do
    new_connection = Capybara::Webkit::Connection.new
    new_connection.port.should_not == connection.port
  end

  let(:connection) { Capybara::Webkit::Connection.new }

  before(:all) do
    @app = lambda do |env|
      body = "<html><body>Hey there</body></html>"
      [200,
        { 'Content-Type' => 'text/html', 'Content-Length' => body.size.to_s },
        [body]]
    end
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot
  end
end
