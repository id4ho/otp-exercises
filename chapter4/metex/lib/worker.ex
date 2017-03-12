defmodule Metex.Worker do
  use GenServer

  alias HTTPoison.Response

  @name MW

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: @name])
  end

  def get_temperature(location) do
    GenServer.call(@name, {:location, location})
  end

  def get_stats do
    GenServer.call(@name, :get_stats)
  end

  def reset_stats do
    GenServer.cast(@name, :reset_stats)
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temp} ->
        new_stats = update_stats(stats, location)
        {:reply, "#{temp}°C", new_stats}
      _ ->
        {:reply, :error, stats}
    end
  end

  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def terminate(reason, stats) do
    IO.puts "server terminated because of #{inspect reason}"
    IO.inspect stats
    :ok
  end

  ## Helper Functions

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))
      false ->
        Map.put_new(old_stats, location, 1)
    end
  end

  defp temperature_of(location) do
    url()
    |> HTTPoison.get([], query_params(location))
    |> parse_response
  end

  defp query_params(location) do
    [
      params: [
        appid: app_id(),
        q: URI.encode(location),
      ],
    ]
  end

  defp parse_response({:ok, %Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!
    |> compute_temperature
  end
  defp parse_response(_resp), do: :error

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp url do
    "http://api.openweathermap.org/data/2.5/weather"
  end

  defp app_id do
    "5745d356ad44c92b3d232320c2a5a92a"
  end
end
