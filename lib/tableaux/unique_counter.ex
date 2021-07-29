defmodule UniqueCounter do
  use GenServer

  def reset(), do: GenServer.cast(UniqueCounter, :reset)

  def increment(), do: GenServer.cast(UniqueCounter, :increment)

  def get_value(), do: GenServer.call(UniqueCounter, :get_data)

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: UniqueCounter)
  end

  def init(_) do
    {:ok, 0}
  end

  def handle_call(:get_data, _, state) do
    {:reply, state, state}
  end

  def handle_cast(:increment, state) do
    {:noreply, state+1}
  end

  def handle_cast(:reset, _state) do
    {:noreply, 0}
  end
end
