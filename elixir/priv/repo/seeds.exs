# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Homework.Repo.insert!(%Homework.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias Homework.Repo
alias Homework.Companies.Company
alias Homework.Merchants.Merchant
alias Homework.Transactions.Transaction
alias Homework.Users.User

Repo.delete_all(Transaction)
Repo.delete_all(User)
Repo.delete_all(Company)
Repo.delete_all(Merchant)

num_companies = 5

Enum.each(0..num_companies, fn _n ->
  %Company{
    available_credit: 10000,
    credit_line: 10000,
    name: Faker.Company.name()
  }
  |> Repo.insert!()
end)

num_users = 5

Enum.each(0..num_users, fn _n ->
  %User{
    first_name: Faker.Person.first_name(),
    last_name: Faker.Person.last_name(),
    dob: Faker.Date.date_of_birth(18..99) |> Date.to_string(),
    company_id:
      Repo.one(from(c in Company, order_by: fragment("RANDOM()"), select: c.id, limit: 1))
  }
  |> Repo.insert!()
end)

num_merchants = 5

Enum.each(0..num_merchants, fn _n ->
  %Merchant{
    description: Faker.Company.catch_phrase(),
    name: Faker.Company.name()
  }
  |> Repo.insert!()
end)

num_transactions = 15

Enum.each(0..num_transactions, fn _n ->
  debit = Faker.Util.pick([true, false])

  %Transaction{
    amount: Enum.random(1..5000),
    credit: !debit,
    debit: debit,
    description: Faker.Commerce.product_name(),
    company_id:
      Repo.one(from(c in Company, order_by: fragment("RANDOM()"), select: c.id, limit: 1)),
    merchant_id:
      Repo.one(from(m in Merchant, order_by: fragment("RANDOM()"), select: m.id, limit: 1)),
    user_id: Repo.one(from(u in User, order_by: fragment("RANDOM()"), select: u.id, limit: 1))
  }
  |> Repo.insert!()
end)
