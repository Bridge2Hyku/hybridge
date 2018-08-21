require_dependency "hybridge/application_controller"

module Hybridge
  class IngestController < Hyrax::MyController
    include Hyrax::Breadcrumbs
    before_action :set_current_account, :authenticate_user!
    skip_before_action :require_active_account!

    def index
      add_breadcrumbs
      @packages = packages
    end

    def perform
    end

    private
    
    def add_breadcrumbs
      add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hybridge.admin.sidebar.ingest'), hybridge.root_path
    end

    def set_current_account
      @account = Site.account
    end

    def location
      File.join(Settings.hybridge.filesystem, @account.cname)
    end

    def packages
      files = Dir.glob(location + '/**/*.csv')
      base_path = Pathname.new(location)
      files = files.collect do |file|
        Pathname.new(file).relative_path_from(base_path)
      end
    end

  end
end