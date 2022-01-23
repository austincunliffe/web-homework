defmodule Homework.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Homework.Repo

  alias Homework.Transactions.Transaction
  alias Homework.Companies

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions([])
      [%Transaction{}, ...]

  """
  def list_transactions(_args) do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    multi =
      Multi.new()
      |> Multi.insert(:insert_transaction, %Transaction{} |> Transaction.changeset(attrs))
      |> Multi.run(:update_company_available_credit_step, update_company_available_credit())

    case Repo.transaction(multi) do
      {:ok, %{transaction: transaction}} ->
        {:ok, transaction}

      error ->
        {:error, error}
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction_changeset = change_transaction(transaction, attrs)

    multi =
      Multi.new()
      |> Multi.update(:update_transaction_step, transaction_changeset)
      |> Multi.run(
        :update_company_available_credit_step,
        update_company_available_credit(transaction_changeset)
      )

    case Repo.transaction(multi) do
      {:ok, %{transaction: transaction}} ->
        {:ok, transaction}

      error ->
        {:error, error}
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    multi =
      Multi.new()
      |> Multi.delete(:delete_transaction, transaction)
      |> Multi.run(
        :update_company_available_credit_step,
        update_company_available_credit(transaction)
      )

    case Repo.transaction(multi) do
      {:ok, %{transaction: transaction}} ->
        {:ok, transaction}

      error ->
        {:error, error}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  @doc """
  Gets all transactions between a min and max range.

  ## Examples

      iex> search_transactions_by_range(1200, 2000)
      [%Transaction{}, ...]

  """
  def get_transactions_within_range(min, max) do
    query =
      from(t in Transaction,
        where: fragment("? BETWEEN ? AND ?", t.amount, ^min, ^max)
      )

    Repo.all(query)
  end

  defp update_company_available_credit() do
    fn repo, %{insert_transaction: %{ok: transaction}} ->
      company = Companies.get_and_lock_company!(transaction.company_id)

      available_credit_adjustment =
        if transaction.debit, do: -transaction.amount, else: transaction.amount

      updated_available_credit = company.available_credit + available_credit_adjustment

      company
      |> Companies.change_company(%{available_credit: updated_available_credit})
      |> repo.update()
    end
  end

  defp update_company_available_credit(transaction) do
    fn repo, _ ->
      company = Companies.get_and_lock_company!(transaction.company_id)

      available_credit_adjustment =
        if transaction.debit, do: -transaction.amount, else: transaction.amount

      updated_available_credit = company.available_credit + available_credit_adjustment

      company
      |> Companies.change_company(%{available_credit: updated_available_credit})
      |> repo.update()
    end
  end

  defp update_company_available_credit(%{data: original_data, changes: changes} = _changeset) do
    fn repo, %{update_transaction_step: %{ok: transaction}} ->
      company = Companies.get_and_lock_company!(original_data.company_id)

      updated_available_credit =
        company.available_credit
        |> reverse_transaction_amount_from_available_credit(original_data, changes)
        |> update_available_credit_for_new_transaction(transaction)

      company
      |> Companies.change_company(%{available_credit: updated_available_credit})
      |> repo.update()
    end
  end

  defp reverse_transaction_amount_from_available_credit(
         available_credit,
         original_transaction,
         transaction_changes
       ) do
    if Enum.any?(
         ["company_id", "debit", "credit", "amount"],
         &Map.has_key?(transaction_changes, &1)
       ) do
      available_credit_adjustment =
        if original_transaction.debit,
          do: original_transaction.amount,
          else: -original_transaction.amount

      ^available_credit = available_credit + available_credit_adjustment
    end

    available_credit
  end

  defp update_available_credit_for_new_transaction(available_credit, transaction) do
    available_credit_adjustment =
      if transaction.debit, do: -transaction.amount, else: transaction.amount

    available_credit = available_credit + available_credit_adjustment
    available_credit
  end
end
