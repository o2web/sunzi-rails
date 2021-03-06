require 'sunzi'
require 'minitest/autorun'

class TestCli < Minitest::Test
  def setup
    @cli = Sunzi::Cli.new
  end

  def test_parse_target
    assert_equal ['user', 'example.com', '2222'], @cli.parse_target('user@example.com:2222')
    assert_equal ['root', 'example.com', '2222'], @cli.parse_target('example.com:2222')
    assert_equal ['user', 'example.com', '22'],   @cli.parse_target('user@example.com')
    assert_equal ['root', 'example.com', '22'],   @cli.parse_target('example.com')
    assert_equal ['root', '192.168.0.1', '22'],   @cli.parse_target('192.168.0.1')
  end

  def test_parse_target_with_ssh_config
    ssh_config = lambda do |host|
      if host == 'example.com'
        { :host_name => "buzz.example.com", :user => "foobar", :port => 2222 }
      else
        {}
      end
    end

    Net::SSH::Config.stub(:for, ssh_config) do
      assert_equal ['foobar', 'buzz.example.com', '2222'], @cli.parse_target('example.com')
      assert_equal ['foobar', 'buzz.example.com', '8080'], @cli.parse_target('example.com:8080')
      assert_equal ['piyo', 'buzz.example.com', '2222'], @cli.parse_target('piyo@example.com')
      assert_equal ['piyo', 'buzz.example.com', '8080'], @cli.parse_target('piyo@example.com:8080')
      assert_equal ['root', '192.168.0.1', '22'], @cli.parse_target('192.168.0.1')
    end
  end

  def test_create
    @cli.create
    assert File.exist?('config/sunzi/sunzi.yml')
    FileUtils.rm_rf 'config/sunzi'
  end

  def test_copy_local_files
    pwd = Dir.pwd
    Dir.chdir('test/sunzi_test_dir')

    @cli.copy_local_files({}, :copy_file)
    assert File.exists?('compiled/files/nginx/nginx.conf')
    assert File.exists?('compiled/recipes/nginx.sh')
    FileUtils.rm_rf 'compiled'

    Dir.chdir(pwd)
  end
end
