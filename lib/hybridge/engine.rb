module Hybridge
  class Engine < ::Rails::Engine
    isolate_namespace Hybridge
    
    config.after_initialize do
      hybridge_root = root.to_s
      paths = ActionController::Base.view_paths.collect{|p| p.to_s}
      paths = paths.unshift(hybridge_root + '/app/views')
      ActionController::Base.view_paths = paths
    end
  end
end
