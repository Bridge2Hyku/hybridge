class Hybridge::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def inject_routes
    insert_into_file "config/routes.rb", after: ".draw do" do
      %(\n  mount Hybridge::Engine => '/hybridge'\n)
    end
  end

  def inject_dashboard_link
    file_path = "app/views/hyrax/dashboard/_sidebar.html.erb"
    if File.file?(file_path)
      insert_into_file file_path, after: /menu\.nav_link\(hyrax\.my_works_path.*?<% end %>/m do
        "\n\n  <%= menu.nav_link(hybridge.root_path,\n" \
        "                        also_active_for: hyrax.dashboard_works_path) do %>\n" \
        "    <span class=\"fa fa-magic\"></span> <span class=\"sidebar-action-text\"><%= t('hybridge.admin.sidebar.ingest') %></span>\n" \
        "  <% end %>\n"
      end
    end
    copy_file "sidebar/_repository_content.html.erb", "app/views/hyrax/dashboard/sidebar/_repository_content.html.erb"
  end

end