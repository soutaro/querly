require_relative "../test_helper"
require "querly/cli/console"
require "pty"

class ConsoleTest < Minitest::Test
  include TestHelper

  def exe_path
    Pathname(__dir__) + "../../exe/querly"
  end

  def read_for(read, pattern:)
    timeout_at = Time.now + 3
    result = ""

    while true
      if Time.now > timeout_at
        raise "Timedout waiting for #{pattern}"
      end

      buf = ""
      read.read_nonblock 1024, buf rescue IO::EAGAINWaitReadable

      if buf == ""
        sleep 0.1
      else
        result << buf.force_encoding(Encoding::UTF_8)
      end

      if pattern =~ result
        break
      end
    end

    result
  end

  def test_console
    mktmpdir do |path|
      (path + "foo.rb").write(<<-EOF)
class UsersController
  def create
    User.create!(params[:user])
  end
end
      EOF

      PTY.spawn({ "NO_COLOR" => "true" }, exe_path.to_s, "console", chdir: path.to_s) do |read, write, pid|
        read_for(read, pattern: /^> $/)

        write.puts "reload!"
        read.gets
        read_for(read, pattern: /^> $/)

        write.puts "find create!"
        read.gets
        output = read_for(read, pattern: /^> $/)
        assert_match /#{Regexp.escape "User.create!(params[:user])"}/, output

        write.puts "find crea te !!"
        read.gets
        output = read_for(read, pattern: /^> $/)
        assert_match /#{Regexp.escape "parse error on value"}/, output

        write.puts "no such command"
        read.gets
        output = read_for(read, pattern: /^> $/)
        assert_match /#{Regexp.escape "Commands:"}/, output

        write.puts "quit"
        read.gets

        assert_nil read.gets
      end

      history = path + ".querly_history"
      assert_equal ["reload!", "find create!", "find crea te !!", "no such command"], history.readlines.map(&:chomp)
    end
  end
end
