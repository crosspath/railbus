module Railbus::RouteSetPresenter
  module_function

  def to_h(route_set)
    result = {}
    route_set.paths.each do |route|
      result[route.name] = route.to_h
    end
    result
  end
end
