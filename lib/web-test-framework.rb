require 'rubygems'
require 'tmpdir'
require 'tempfile'
require 'webrick'
require 'pp'
require 'nagios-support'

module WebTestFramework
  class SimpleTest

    include NagiosSupport

    def initialize(script_filename, port='98888')
      @tempfile = Tempfile.new('tmp')
      @test_server = HTTPTestServer.new(port)
      @script_filename = script_filename
    end

    def fixture_path
      File.dirname(__FILE__)
    end

    def script_path
      File.dirname(__FILE__)
    end

    def destroy
      @tempfile.close
      @tempfile.unlink
      @test_server.terminate

    end
    def run_via_cli(args)
      `cd #{script_path}; /usr/bin/ruby #{script_path}/#{@script_filename} #{args}`
    end

    def setup_test_server_with_fixture(fixture_file, response_code = 200)
      @test_server.start(['/']) do |request, response|
        response.status = response_code
        response.body = File.read("#{fixture_path}/#{fixture_file}")
      end
    end

  end

  class TestServlet < WEBrick::HTTPServlet::AbstractServlet
    def initialize(&block)
      @block = block
    end

    def do_DELETE(req, res)
      @block.call(req, res)
    end

    def do_GET(req, res)
      @block.call(req, res)
    end

    def do_PUT(req, res)
      # For some reason if we don't read the body _here_, we can't read
      # it inside the block.
      req.body
      @block.call(req, res)
    end

    def do_POST(req, res)
      req.body
      @block.call(req, res)
    end

    def get_instance(server, *options)
      self
    end
  end

  class HTTPTestServer
    attr_reader :requests_received

    def initialize(port=1212)
      @port = port
      @requests_received = []
      @thread = nil
    end

    def start(uris, &block)
      @http_server = WEBrick::HTTPServer.new :Port => @port, :Logger => WEBrick::Log.new("/dev/null"), :AccessLog => []
      servlet = TestServlet.new do |req, res|
        res.header['Content-Type'] = 'application/json'
        @requests_received << req
        block.call req, res if block
      end
      uris.each do |uri|
        @http_server.mount uri, servlet
      end

      @thread = Thread.new do
        @http_server.start
      end

      # If we get all the way through a test and run terminate before the
      # server is running, terminate freezes.
      while @http_server.status != :Running
        sleep 0.01
      end
    end

    def get_data
      @data
    end

    def terminate
      #print "dammit"
      #debugger
      if @http_server
        @http_server.shutdown
        @thread.join
      end
    end
  end
end

