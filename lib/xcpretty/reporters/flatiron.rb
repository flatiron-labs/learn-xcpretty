module XCPretty
  class Flatiron

    include XCPretty::FormatMethods

    def load_dependencies
      unless @@loaded ||= false
        require 'fileutils'
        require 'pathname'
        require 'json'
        require 'faraday'
        @@loaded = true
      end
    end

    def initialize(options)
      load_dependencies
      @json_output = {}
      @json_output["tests"]={}
      @json_output["tests"]["passing"]={}
      @json_output["tests"]["failing"]={}
      @json_output["lines"]=[]

      @parser = Parser.new(self)

      @test_count = 0
      @fail_count = 0

      @connection = Faraday.new(url: "http://localhost:4567") do |faraday|
          faraday.adapter  Faraday.default_adapter
        end
    end

    def handle(line)
      @parser.parse(line)
      @json_output["lines"] << line
    end

    def format_passing_test(classname, test_case, time)
      @json_output["tests"]["passing"][classname]||=[]
      pass = {"name"=>test_case, "time" => time}
      @json_output["tests"]["passing"][classname]<<pass;
      @test_count += 1
    end
    def format_failing_test(classname, test_case, reason, file)
      @json_output["tests"]["failing"][classname]||=[]
      failure = {"name"=>test_case, "file" => file, "reason" => reason}
      @json_output["tests"]["failing"][classname]<<failure;
      @test_count += 1
      @fail_count += 1
    end

    def finish
      @json_output["summary"] ={}
      @json_output["summary"]["test_count"]=@test_count
      @json_output["summary"]["failure_count"] = @fail_count
      write_report_file
    end

    private

    def write_report_file
      @connection.post do |req|
        req.url '/'
        req.headers['Content-Type'] = 'application/json'
        req.body = @json_output.to_json
      end
    end
  end
end
