require 'test_helper'

module Hybridge
  class IngestControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get ingest_index_url
      assert_response :success
    end

  end
end
