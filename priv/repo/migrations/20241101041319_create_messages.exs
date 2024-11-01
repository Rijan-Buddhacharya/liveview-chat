defmodule Chat.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false
      add :username, :string, null: false

      timestamps()
    end
  end
end
