class Hybridge::InstallGenerator < Rails::Generators::Base
  def inject_routes
    insert_into_file "config/routes.rb", after: ".draw do" do
      %(\n  mount Hybridge::Engine => '/hybridge'\n)
    end
  end
end