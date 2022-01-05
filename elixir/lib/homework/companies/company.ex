defmodule Homework.Companies.Company do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "companies" do
    field(:available_credit, :integer)
    field(:credit_line, :integer)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:available_credit, :credit_line, :name])
    |> validate_required([:available_credit, :credit_line, :name])
  end
end
