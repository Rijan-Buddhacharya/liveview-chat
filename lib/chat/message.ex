defmodule Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "messages" do
    field :content, :string
    field :username, :string
    field :email, :string

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :username, :email])
    |> validate_required([:content, :username, :email])
  end

  def list_messages do
    Chat.Repo.all(
      from m in __MODULE__,
        order_by: [desc: m.inserted_at],
        limit: 100
    )
  end

  def create_message(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Chat.Repo.insert()
  end
end
