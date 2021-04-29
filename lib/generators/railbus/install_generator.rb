require 'rails/generators/base'

module Railbus
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Install dependencies and example file with routes'

      def install
        # It's important to reset `Dir.pwd` because it's set to
        # parent dir of `Rails.root` while running `rails new` command.
        Dir.chdir(::Rails.root) do
          exit unless run 'yarn add @crosspath/yambus @crosspath/yambus-axios'
        end

        create_file('app/javascript/lib/routes.js.erb') do |f|
          <<-LINE
/* rails-erb-loader-dependencies ../config/routes */
<%= Railbus.generate %>
          LINE
        end

        puts 'Railbus installed!'
      end
    end
  end
end
