require 'test_helper'

module Hybridge
  class HelloControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get hello_index_url
      assert_response :success
    end

  end
end
