defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  alias Phoenix.PubSub
  alias Chat.Message

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Chat.PubSub, "chat_room")
    end

    {:ok,
     assign(socket,
       page_title: "Chat Room",
       messages: Message.list_messages(),
       current_message: "",
       username: "user#{:rand.uniform(1000)}",
       user_email: "user@example.com" # Change this to get the actual user email if needed
     )}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    if String.trim(message) != "" do
      message_attrs = %{
        content: message,
        username: socket.assigns.username,
        email: socket.assigns.user_email,
        inserted_at: NaiveDateTime.utc_now() # Changed from :timestamp to :inserted_at
      }

      case Message.create_message(message_attrs) do
        {:ok, message} ->
          PubSub.broadcast(Chat.PubSub, "chat_room", {:new_message, message})
          {:noreply, assign(socket, current_message: "")}

        {:error, _changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Could not save message")
           |> assign(current_message: message)}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("form_update", %{"message" => message}, socket) do
    {:noreply, assign(socket, current_message: message)}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, update(socket, :messages, &[message | &1])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <.header>
        Chat Room
        <:subtitle>Logged in as: <%= @username %></:subtitle>
      </.header>

      <div class="mt-4 space-y-4">
        <div class="h-[32rem] overflow-y-auto rounded-lg border bg-white p-4">
          <%= for message <- @messages do %>
            <div class="mb-4 rounded-lg bg-gray-50 p-4">
              <div class="flex items-start justify-between">
                <div class="flex items-center space-x-2">
                  <.icon name="hero-user-circle" class="h-5 w-5 text-gray-400" />
                  <span class="font-semibold text-gray-900"><%= message.username %></span>
                </div>
                <span class="text-sm text-gray-500">
                  <%= Calendar.strftime(message.inserted_at, "%Y-%m-%d %H:%M:%S") %> <!-- Changed to inserted_at -->
                </span>
              </div>
              <p class="mt-2 text-gray-700"><%= message.content %></p>
              <p class="mt-1 text-xs text-gray-500">Sent by: <%= message.email %></p>
            </div>
          <% end %>
        </div>

        <.form for={%{}} phx-submit="send_message" class="space-y-4">
          <.input
            type="text"
            name="message"
            value={@current_message}
            placeholder="Type your message..."
            phx-change="form_update"
            autocomplete="off"
          />
          <.button phx-disable-with="Sending..." class="w-full">
            Send message
          </.button>
        </.form>
      </div>
    </div>
    """
  end
end
