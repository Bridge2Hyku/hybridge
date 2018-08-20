Hybridge::Engine.routes.draw do
  get 'ingest/index'

  root to: "ingest#index"
end
