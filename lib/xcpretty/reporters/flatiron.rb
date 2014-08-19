module XCPretty
  class Flatiron
    SERVICE_URL = 'http://staging.ironbroker.flatironschool.com'
    SERVICE_ENDPOINT = '/e/flatiron_xcpretty/build'

    include XCPretty::FormatMethods

    def load_dependencies
      unless @@loaded ||= false
        require 'fileutils'
        require 'pathname'
        require 'json'
        require 'faraday'
        require 'netrc'
        require 'git'
        require 'oj'
        @@loaded = true
      end
    end

    def initialize(options)
      load_dependencies
      @json_output = {
        "username": UsernameParser.get_username,
        "github_user_id": UserIdParser.get_user_id,
        "repo_name": RepoParser.get_repo,
        "build": {
          "test_suite": [{
            "framework": 'xcpretty',
            "formatted_output": [],
            "duration": 0.0,
            "lines": [],
          }]
        },
        "test_count": 0,
        "pass_count": 0,
        "failure_count": 0
      }

      @parser = Parser.new(self)

      @connection = Faraday.new(url: SERVICE_URL) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    def handle(line)
      @parser.parse(line)
      @json_output["build"]["test_suite"][0]["lines"] << line
    end

    def format_passing_test(classname, test_case, time)
      @json_output["build"]["test_suite"][0]["formatted_output"]["passing"][classname] ||= []
      pass = {"name"=>test_case, "time" => time}
      @json_output["build"]["test_suite"][0]["formatted_output"]["passing"][classname] << pass;
      @json_output["test_count"] += 1
      @json_output["pass_count"] += 1
    end

    def format_failing_test(classname, test_case, reason, file)
      @json_output[["build"]["test_suite"][0]["formatted_output"]["failing"][classname] ||= []
      failure = {"name"=>test_case, "file" => file, "reason" => reason}
      @json_output["build"]["test_suite"][0]["formatted_output"]["failing"][classname] << failure
      @json_output["test_count"] += 1
      @json_output["failure_count"] += 1
    end

    def finish
      write_report_file
    end

    private

    def write_report_file
      @connection.post do |req|
        req.url SERVICE_ENDPOINT
        req.headers['Content-Type'] = 'application/json'
        req.body = @json_output.to_json
      end
    end
  end

  class UsernameParser
    def self.get_username
      parser = NetrcInteractor.new
      username = parser.username

      if !username
        print "Enter your github username: "
        username = gets.strip
        user_id = GitHubInteractor.get_user_id_for(username)
        parser.write(username, user_id)
      end

      username
    end
  end

  class UserIdParser
    def self.get_user_id
      parser = NetrcInteractor.new
      user_id = parser.user_id
    end
  end

  class GitHubInteractor
    attr_reader :username, :user_id

    def self.get_user_id_for(username)
      new(username).get_user_id
    end

    def initialize(username)
      @username = username
    end

    def get_user_id
      @user_id ||= Oj.load(
        open("https://api.github.com/users/#{username}").read,
        symbol_keys: true
      )[:id]
    end
  end

  class NetrcInteractor
    attr_reader :username, :user_id, :netrc

    def initialize
      @netrc = Netrc.read
      @username, @user_id = netrc["flatiron-push"]
    end

    def write(username, user_id)
      netrc["flatiron-push"] = username, user_id
      netrc.save
    end
  end

  class RepoParser
    def self.get_repo
      begin
        repo = Git.open(File.expand_path("..", Dir.pwd))
      rescue
        puts "Not a valid Git repository"
        die
      end

      url = repo.remote.url

      repo_name = url.match(/(?:https:\/\/|git@).*\/(.+)(?:\.git)/)[1]
    end

    def self.die
      exit
    end
  end
end
