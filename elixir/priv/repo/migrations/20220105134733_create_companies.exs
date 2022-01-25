defmodule Homework.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:available_credit, :integer)
      add(:credit_line, :integer)
      add(:name, :string)

      timestamps()
    end
  end
end
