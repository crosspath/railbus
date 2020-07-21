require 'json'
require 'erubi'
require 'active_support'

require_relative 'railbus/version'
require_relative 'railbus/route_set'
require_relative 'railbus/route_set_presenter'

module Railbus
  module_function

  def generate(
    app:     Rails.application,
    client:  'axios',
    include: [],
    exclude: []
  )
    route_set   = RouteSet.new(app, include, exclude)
    routes_json = Railbus::RouteSetPresenter.to_h(route_set).to_json

    js_template = File.join(__dir__, 'railbus', 'templates', 'js.erb')
    erb_engine  = Erubi::Engine.new(File.read(js_template))

    # Template uses `routes_json`, `client`
    client = client.to_s
    eval(erb_engine.src)
  end
end
