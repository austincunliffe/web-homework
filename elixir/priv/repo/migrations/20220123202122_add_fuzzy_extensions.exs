defmodule Homework.Repo.Migrations.AddFuzzyExtensions do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
    execute "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch"
  end

  def down do
    execute "DROP EXTENSION IF EXISTS fuzzystrmatch"
    execute "DROP EXTENSION IF EXISTS pg_trgm"
  end
end
