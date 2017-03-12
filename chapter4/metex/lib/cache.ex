defmodule Metex.Cache do
  use GenServer

  @name Cache

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: @name])
  end

  def write(key, value) do
    GenServer.cast(@name, {:write, {key, value}})
  end

  def read(key) do
    GenServer.call(@name, {:read, key})
  end

  def exist?(key) do
    GenServer.call(@name, {:exists, key})
  end

  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end

  def current_state do
    GenServer.call(@name, :current_state)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  ## Server Callbacks

  def init(opts \\ []) do
    {:ok, %{}}
  end

  def handle_cast({:write, {k, v}}, state) do
    {:noreply, Map.put(state, k, v)}
  end

  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{}}
  end

  def handle_call({:read, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:exists, key}, _from, state) do
    {:reply, Map.has_key?(state, key), state}
  end

  def handle_call(:current_state, from, state) do
    IO.inspect from
    {:reply, state, state}
  end
end
