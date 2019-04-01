require 'hybridge/batch'
module Hybridge
  class IngestPackageJob < ApplicationJob
    queue_as Hyrax.config.ingest_queue_name

    def perform(package_location, collection_id, current_user)
      Hybridge::Batch::Ingest.new(package_location, collection_id, current_user)
    end
  end
end