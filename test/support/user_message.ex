defmodule MyApp.UserMessage do
  use Herald.Message

  payload do
    field :id, :integer, required: true
    field :name, :string, required: true
  end

  def process(%__MODULE__{} = message) do
    IO.inspect message
    {:ok, message}
  end
end
