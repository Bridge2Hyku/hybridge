require_dependency "hybridge/application_controller"

module Hybridge
  class IngestController < Hyrax::MyController
    include Hyrax::Breadcrumbs
    before_action :set_current_account, :authenticate_user!
    skip_before_action :require_active_account!

    delegate :title, :id, to: :solr_document

    def index
      add_breadcrumbs
      @packages = packages('csv')
      @processing = packages('processing', true)
      @processed = packages('processed', true)
      @collections = collections
    end

    def perform
      if params[:package_id].nil?
        flash[:error] = "Unable to find selected file in source directory. Please contact your System Administrator"
      else
        params[:package_id].each do | package |
          package_location = staged!(File.join(location, package))
          next if package_location.nil?
          collection_id = params[:collection_id][package]
          Hybridge::IngestPackageJob.perform_later(package_location, collection_id, current_user)
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
      @account = Site.account rescue nil
    end

    def location
      if @account.nil?
        Settings.hybridge.filesystem
      else
        File.join(Settings.hybridge.filesystem, @account.cname)
      end
    end

    def packages(ext, hideext=false)
      files = Dir.glob(location + "/**/*.#{ext}")
      base_path = Pathname.new(location)
      files = files.collect do |file|
        path = Pathname.new(file).relative_path_from(base_path)
        if hideext
          path = "#{File.dirname(path)}/#{File.basename(path, ".#{ext}")}"
        end
        path
      end
    end

    def staged!(filename)
      if !File.file?(filename)
        flash[:error] = "Unable to find #{package}. Please contact your System Administrator for assistance"
        return nil
      end
      new_filename = filename + '.staged'
      File.rename(filename, new_filename)
      new_filename
    end

    def collections
      colls = []
      response = self.repository.search(collection_search_builder)
      response.docs.each do |document|
        colls << {
          id: document.id,
          title: document.title.first || document.title
        }
      end
      colls
    end

    private

      def collection_search_builder
        Hyrax::CollectionSearchBuilder.new(self).rows(1000).with_access(:edit)
      end

  end
end