defmodule Chat.Repo.Migrations.AddEmailToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :email, :string
    end
  end
end
