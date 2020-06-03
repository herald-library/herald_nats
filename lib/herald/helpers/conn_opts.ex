defmodule Herald.NATS.Helpers.ConnOpts do
  @moduledoc false

  @valid_keys [
    :host,
    :port,
    :tcp_opts,
    :username,
    :password,
    :auth_required,
    :connection_timeout,
    :ssl_options,
    :tls
  ]

  @type conn_opts :: [
    host: String.t(),
    port: pos_integer(),
    tcp_opts: list(atom()),
    username: String.t(),
    password: String.t(),
    auth_required: boolean(),
    connection_timeout: non_neg_integer(),
    ssl_options: list(any()),
    tls: boolean()
  ]

  @doc """
  Returns `conn_opts` according `Gnat.start_link/1`
  requirements.
  It loads application environment and converts the value of
  `nats_url` into a Map according NATS library requirements.
  For more details, see `Gnat.start_link/1`.
  """
  @spec get() :: conn_opts
  def get() do
    case Application.get_env(:herald, :nats_url) do
      {:system, environment} ->
        System.get_env(environment) || "http://localhost:4222"

      amqp_url ->
        amqp_url || "http://localhost:4222"
    end
    |> URI.parse()
    |> conn_opts_from_uri()
  end

  defp conn_opts_from_uri(%URI{} = info) do
    Map.from_struct(info)
    |> Enum.reduce(Map.new(), fn {key, value}, acc ->
      put_conn_opts(acc, key, value)
    end)
    |> Map.take(@valid_keys)
  end
  
  defp put_conn_opts(info, _key, nil),
    do: info
  defp put_conn_opts(info, :userinfo, value) do
    case String.split(value, ":") do
      [user, ""] ->
        Map.put(info, :username, user)

      ["", password] ->
        Map.put(info, :password, password)

      [user, password] ->
        info
        |> Map.put(:username, user)
        |> Map.put(:password, password)
    end
  end
  defp put_conn_opts(info, :query, value) do
    value
    |> URI.decode_query()
    |> Enum.map(fn {k, v} ->
      case k do
        "connection_timeout" ->
          Map.put(info, :connection_timeout, v |> String.to_integer())

        k ->
          Map.put(info, k |> String.to_atom(), v)  
      end
    end)
    |> List.first()
  end
  defp put_conn_opts(info, key, value) do
    Map.put(info, key, value)
  end
end
