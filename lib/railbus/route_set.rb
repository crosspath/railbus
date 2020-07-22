class Railbus::RouteSet
  # Example:
  # get, /users/:id, ['/users/', {a: 'id'}], ['id'], user
  Route = Struct.new(:verb, :path, :parts, :required, :name)

  %w[post patch put].each do |word|
    Route.define_method("#{word}?") { verb == word }
  end

  MAP_NAMES = {
    'post'   => 'create_',
    'put'    => 'update_',
    'patch'  => 'update_',
    'delete' => 'delete_'
  }

  attr_reader :paths

  def initialize(app, include, exclude)
    @paths = add_route_names(paths_for_app(app, include, exclude))
  end

  private

  def paths_for_app(app, include, exclude)
    app.routes.set.routes.map do |route|
      formatter   = route.instance_variable_get(:@path_formatter)
      route_parts = parts_combined(formatter.instance_variable_get(:@parts))

      path = join_parts(route_parts)
      next nil unless include_path?(path, include, exclude)

      Route.new(
        route.verb.downcase,
        path,
        route_parts,
        required_params(route_parts),
        route.name
      )
    end.compact
  end

  def parts_combined(parts)
    parts.reduce([]) do |a, pt|
      e = parts_element(pt)
      next a if e.empty?
      if a.empty?
        a = [e]
      elsif a[-1].respond_to?(:<<) && e.respond_to?(:<<)
        # Both vars are strings -> concat them.
        a[-1] << e
      else
        a << e
      end
      a
    end
  end

  def parts_element(part)
    if part.respond_to?(:name)
      # Is a path parameter (e.g. `:id`).
      {a: part.name}
    else
      # Is a `format` parameter -> skip it.
      # Otherwise it is a string.
      (part.respond_to?(:evaluate) ? '' : part).dup
    end
  end

  def join_parts(route_parts)
    route_parts.map { |x| x.respond_to?(:<<) ? x : ":#{x[:a]}" }.join
  end

  def required_params(route_parts)
    route_parts.reject { |x| x.respond_to?(:<<) }.map { |x| x[:a] }
  end

  def include_path?(path, include, exclude)
    return false if !include.empty? && include.none? { |re| path =~ re }
    return false if exclude.any? { |re| path =~ re }
    true
  end

  def add_route_names(paths)
    paths.group_by(&:path).flat_map do |_, routes|
      name = routes.find(&:name)&.name
      if name
        routes.reject!(&:patch?) if routes.find(&:put?)
        routes.map do |route|
          route.name ||= "#{MAP_NAMES[route.verb]}#{route_name(route, name)}"
          route
        end
      else
        []
      end
    end.uniq
  end

  def route_name(route, base_name)
    if route.post?
      route_name_for_create(base_name)
    else
      base_name
    end
  end

  def route_name_for_create(base_name)
    if base_name.end_with?('_index')
      base_name.sub(/_index$/, '')
    else
      base_name.singularize
    end
  end
end
