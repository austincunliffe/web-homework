defmodule HomeworkWeb.Resolvers.TransactionsResolver do
  alias Homework.Companies
  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users

  @doc """
  Get a list of transcations
  """
  def transactions(_root, args, _info) do
    {:ok, Transactions.list_transactions(args) |> Enum.map(&amount_to_dollars/1)}
  end

  @doc """
  Get the company associated with a transaction
  """
  def company(_root, _args, %{source: %{company_id: company_id}}) do
    {:ok, Companies.get_company!(company_id)}
  end

  @doc """
  Get the user associated with a transaction
  """
  def user(_root, _args, %{source: %{user_id: user_id}}) do
    {:ok, Users.get_user!(user_id)}
  end

  @doc """
  Get the merchant associated with a transaction
  """
  def merchant(_root, _args, %{source: %{merchant_id: merchant_id}}) do
    {:ok, Merchants.get_merchant!(merchant_id)}
  end

  @doc """
  Create a new transaction
  """
  def create_transaction(_root, args, _info) do
    Map.put(args, :amount, amount_to_cents(args.amount))

    case Transactions.create_transaction(args) do
      {:ok, transaction} ->
        {:ok, transaction |> amount_to_dollars}

      error ->
        {:error, "could not create transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a transaction for an id with args specified.
  """
  def update_transaction(_root, %{id: id} = args, _info) do
    transaction = Transactions.get_transaction!(id)
    Map.put(args, :amount, amount_to_cents(args.amount))

    case Transactions.update_transaction(transaction, args) do
      {:ok, transaction} ->
        {:ok, transaction |> amount_to_dollars}

      error ->
        {:error, "could not update transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a transaction for an id
  """
  def delete_transaction(_root, %{id: id}, _info) do
    transaction = Transactions.get_transaction!(id)

    case Transactions.delete_transaction(transaction) do
      {:ok, transaction} ->
        {:ok, transaction |> amount_to_dollars}

      error ->
        {:error, "could not delete transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Gets a list of transactions between a min and max range.
  """
  def find_transactions(_root, %{min: min, max: max}, _info) do
    {:ok, Transactions.find_transactions(min |> amount_to_cents, max |> amount_to_cents)}
  end

  defp amount_to_cents(amount) do
    if is_float(amount) do
      Decimal.round(amount, 2) |> Decimal.mult(100)
    else
      amount
    end
  end

  defp amount_to_dollars(%{amount: cents} = transaction) do
    Map.put(transaction, :amount, Decimal.div(cents, 100) |> Decimal.round(2))
  end
end
