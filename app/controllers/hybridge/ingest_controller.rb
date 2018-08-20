require_dependency "hybridge/application_controller"

module Hybridge
  class IngestController < Hyrax::MyController
    include Hyrax::Breadcrumbs

    def index
      add_breadcrumbs
    end

    private
    
    def add_breadcrumbs
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hybridge.admin.sidebar.ingest'), main_app.hybridge_path
    end

  end
end
