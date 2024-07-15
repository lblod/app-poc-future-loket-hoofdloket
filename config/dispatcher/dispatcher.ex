defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ],
    any: [ "*/*" ]
  ]

  define_layers [ :static, :web_page, :api_services, :not_found ]

  ###############
  # STATIC
  ###############
  get "/assets/*path", %{ layer: :static } do
    forward conn, path, "http://frontend/assets/"
  end

  get "/@appuniversum/*path", %{ layer: :static } do
    forward conn, path, "http://frontend/@appuniversum/"
  end

  get "/favicon.ico", %{ layer: :static } do
    send_resp( conn, 404, "" )
  end

  #################
  # FRONTEND PAGES
  #################
  get "/*path", %{ layer: :web_page, accept: %{ html: true } } do
    forward conn, [], "http://frontend/index.html"
  end

  ###############
  # API SERVICES
  ###############
  post "/sessions", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, [], "http://login/sessions"
  end

  get "/sessions/current", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, [], "http://login/sessions/current"
  end

  delete "/sessions/current", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, [], "http://login/sessions/current"
  end

  get "/public-services/*path", %{ layer: :api_services, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/public-services/"
  end

  get "/concepts/*path", %{ layer: :api_services, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/concepts/"
  end

  get "/websites/*path", %{ layer: :api_services, accept: %{ json: true } } do
    Proxy.forward conn, path, "http://cache/websites/"
  end

  get "/uri-info/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://uri-info/"
  end

  get "/resource-labels/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://resource-labels-cache/"
  end

  #################
  # NOT FOUND
  #################
  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end

end
