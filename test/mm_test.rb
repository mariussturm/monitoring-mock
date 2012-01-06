require File.expand_path('test_helper.rb', 'test')

class GET_baseurl < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    get '/'
  end

  def test_succeeds
    assert last_response.status, 200
  end

  def test_returns_valid_json
    assert_equal json_response['status'], 3
  end
end

class GET_existing_entry < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    get '/green'
  end

  def test_succeeds
    assert_equal json_response['status'], 0
  end
end

class GET_nonexisting_entry < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    get '/yellow'
  end

  def test_succeeds
    assert_equal json_response['status'], 3
  end
end

class POST_toggle_entry < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  @before, @after = ''
  def setup
    get '/green'
    @before = json_response
    post '/toggle/green'
    get '/green'
    @after = json_response
  end

  def test_succeeds
    assert_equal @before['status'], 0
    assert_equal @after['status'], 2
  end
end

class GET_deep_entry_and_toggle_above < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  @before, @after = ''
  def setup
    get '/blue/web2'
    @before = json_response
    post '/toggle/blue'
    get '/blue/web2'
    @after = json_response
  end

  def test_succeeds
    assert_equal @before['status'], 0
    assert_equal @after['status'], 2
  end
end

