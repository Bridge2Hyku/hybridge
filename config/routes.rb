Hybridge::Engine.routes.draw do
  get 'hello/index'

  root to: "hello#index"
end
