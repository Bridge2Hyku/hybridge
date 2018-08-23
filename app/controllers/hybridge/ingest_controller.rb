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
      if params[:package_id].nil?
        flash[:error] = "Unable to find selected file in source directory. Please contact your System Administrator"
      else
        params[:package_id].each do | package |
          package_location = staged!(File.join(location, package))
          Hybridge::IngestPackageJob.perform_later(package_location, current_user)
        end
        flash[:notice] = "Successfully started the ingest process. This can take awhile"
      end
      redirect_to hybridge.root_path
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

    def staged!(filename)
      # TODO: error if filename doesn't exist
      new_filename = filename + '.staged'
      File.rename(filename, new_filename)
      new_filename
    end

  end
end