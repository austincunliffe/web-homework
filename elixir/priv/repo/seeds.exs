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

alias Homework.Repo
alias Homework.Merchants.Merchant
alias Homework.Transactions.Transaction
alias Homework.Users.User

Repo.delete_all Merchant
Repo.delete_all Transaction
Repo.delete_all User

num_users = 5

Enum.each(0..num_users, fn _n ->
  %User{
    first_name: Faker.Person.first_name,
    last_name: Faker.Person.last_name,
    dob: Faker.Date.date_of_birth(18..99) |> Date.to_string
  } |> Repo.insert! end)
