require 'rails/generators/active_record'

class Doorkeeper::ApplicationValidScopesGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  desc 'Provide support for client application ownership.'

  def application_owner
    migration_template 'add_valid_scopes_to_application_migration.rb', 'db/migrate/add_valid_scopes_to_application.rb'
  end

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end
end
