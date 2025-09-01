defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ],
    any: [ "*/*" ]
  ]

  define_layers [ :static, :web_page, :api_services, :not_found ]

  #########################
  # STATIC & FRONTEND PAGES
  #########################

  get "/favicon.ico", %{ layer: :static } do
    send_resp( conn, 404, "" )
  end

  # This section is available three times: [ design, development, general ]
  # once we are out of the development stage of the frontend, the distinction will shift away

  # design branch

  get "/assets/*path", %{ layer: :static, reverse_host: ["design" | _rest ] } do
    forward conn, path, "http://frontend-design/assets/"
  end

  get "/@appuniversum/*path", %{ layer: :static, reverse_host: ["design" | _rest ] } do
    forward conn, path, "http://frontend-design/@appuniversum/"
  end

  get "/*path", %{ layer: :web_page, accept: %{ html: true }, reverse_host: ["design" | _rest ] } do
    forward conn, [], "http://frontend-design/index.html"
  end

  # development branch

  get "/assets/*path", %{ layer: :static, reverse_host: ["dev" | _rest ] } do
    forward conn, path, "http://frontend-development/assets/"
  end

  get "/@appuniversum/*path", %{ layer: :static, reverse_host: ["dev" | _rest ] } do
    forward conn, path, "http://frontend-development/@appuniversum/"
  end

  get "/*path", %{ layer: :web_page, accept: %{ html: true }, reverse_host: ["dev" | _rest ] } do
    forward conn, [], "http://frontend-development/index.html"
  end

  # latest / production -- NOTE: this is last so we don't have to introduce another layer
  get "/assets/*path", %{ layer: :static } do
    forward conn, path, "http://frontend/assets/"
  end

  get "/@appuniversum/*path", %{ layer: :static } do
    forward conn, path, "http://frontend/@appuniversum/"
  end

  get "/*path", %{ layer: :web_page, accept: %{ html: true } } do
    forward conn, [], "http://frontend/index.html"
  end


  ###############
  # API SERVICES
  ###############
  match "/mock/sessions/*path" do
    forward conn, path, "http://mock-login/sessions/"
  end

  post "/sessions", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, [], "http://login/sessions"
  end

  get "/sessions/current", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, [], "http://login/sessions/current"
  end

  delete "/sessions/current", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, [], "http://login/sessions/current"
  end

  get "/public-services/search/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://search/public-services/search/"
  end

  get "/bookmarks/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://ipdc-bookmarks/bookmarks/"
  end

  post "/public-services/:id/bookmarks", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, [], "http://ipdc-bookmarks/public-services/" <> id <> "/bookmarks"
  end

  delete "/bookmarks/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://ipdc-bookmarks/bookmarks/"
  end

  get "/public-services/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://cache/public-services/"
  end

  get "/procedures/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://cache/procedures/"
  end

  get "/accounts/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://cache/accounts/"
  end

  get "/administrative-units/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://cache/administrative-units/"
  end

  get "/concepts/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://cache/concepts/"
  end

  get "/websites/*path", %{ layer: :api_services, accept: %{ json: true } } do
    forward conn, path, "http://cache/websites/"
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
