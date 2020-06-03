defmodule Herald.NATSTest do
  use ExUnit.Case

  alias Herald.NATS

  setup_all do
    message = %{
      "id" => UUID.uuid4(),
      "name" => "Test"
    }

    {_, response} = NATS.start_link([])

    %{message: message, conn: response}
  end

  describe "With NATS so" do
    test "should connect to broker", %{conn: conn} do
      assert(
        not is_nil(conn)
        and is_pid(conn)
      )
    end

    test "should process message from broker", %{conn: conn, message: message} do
      :ok = Gnat.pub(conn, "user:created", message)

      assert(
        not is_nil(conn)
        and is_pid(conn)
      )
    end
  end
end
