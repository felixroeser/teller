class EnablePostgresUuid < ActiveRecord::Migration
  def up
    execute 'create extension IF NOT EXISTS "uuid-ossp"'
    execute 'create extension IF NOT EXISTS "hstore"'
  end
  def down
    execute 'drop extension "uuid-ossp"'
    execute 'drop extension "hstore"'
  end
end
