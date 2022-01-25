defmodule HomeworkWeb.Schemas.CompaniesSchema do
  @moduledoc """
  Defines the graphql schema for company.
  """
  use Absinthe.Schema.Notation

  alias HomeworkWeb.Resolvers.CompaniesResolver

  object :company do
    field(:id, non_null(:id))
    field(:available_credit, :integer)
    field(:credit_line, :integer)
    field(:name, :string)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)
  end

  object :company_queries do
    @desc "Get all Companies"
    field(:companies, list_of(:company)) do
      resolve(&CompaniesResolver.companies/3)
    end
  end

  object :company_mutations do
    @desc "Create a new company"
    field :create_company, :company do
      arg(:available_credit, non_null(:integer))
      arg(:credit_line, non_null(:integer))
      arg(:name, non_null(:string))

      resolve(&CompaniesResolver.create_company/3)
    end

    @desc "Update a company"
    field :update_company, :company do
      arg(:id, non_null(:id))
      arg(:available_credit, non_null(:integer))
      arg(:credit_line, non_null(:integer))
      arg(:name, non_null(:string))

      resolve(&CompaniesResolver.update_company/3)
    end

    @desc "delete an existing company"
    field :delete_company, :company do
      arg(:id, non_null(:id))

      resolve(&CompaniesResolver.delete_company/3)
    end
  end
end
