defmodule Herald.NATS do
  @moduledoc false
  require Logger

  use GenServer

  alias Herald.Pipeline
  alias Herald.NATS.Helpers.ConnOpts

  @conn_max_attempts 5

  @doc false
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [
      name: __MODULE__
    ])
  end

  @doc false
  def init(:ok) do
   connect_with_broker() 
   |> queue_subscription() 
  end

  def handle_call({:pub, topic, message, _timeout}, {conn, _ref}, _state) do
    message = Jason.encode!(message)
    Gnat.pub(conn, topic, "test")
  end

  @spec connect_with_broker(attempt :: pos_integer()) :: any() 
  defp connect_with_broker(attempt \\ 1) do
    ConnOpts.get()
    |> Gnat.start_link()
    |> case do
      {:ok, pid} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error("[#{__MODULE__}] Failed to connect to NATS Broker. [#{attempt}]")
        if attempt > @conn_max_attempts do
          Process.sleep(300)

          attempt
          |> Kernel.+(1)
          |> connect_with_broker()
        else
          {:error, reason}
        end
    end
  end

  @spec queue_subscription({:error, term} | {:ok, pid()} | pid()) :: {:ok, pid()} | {:error, term}
  defp queue_subscription({{:error, reason}}),
    do: {:error, reason}
  defp queue_subscription({:ok, conn}),
    do: queue_subscription(conn)
  defp queue_subscription(conn) when is_pid(conn) do
    Application.get_env(:herald, :router)
    |> apply(:routes, [])
    |> Enum.each(fn {queue, _} ->
      Gnat.sub(conn, self(), queue)
    end)
    
    {:ok, conn}
  end
end
