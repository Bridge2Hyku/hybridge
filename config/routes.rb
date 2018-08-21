Hybridge::Engine.routes.draw do
  get 'ingest/index'
  match '/perform', to: "ingest#perform", via: :post

  root to: "ingest#index"
end
