defmodule Metex.Worker do
  alias HTTPoison.Response

  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})
      _ ->
        IO.puts "Don't know how to process this message"
    end
    loop()
  end

  def temperatures_of(cities) do
    coordinator_pid = spawn(Metex.Coordinator, :loop, [length(cities)])
    cities
    |> Enum.each(fn (city) ->
      worker_pid = spawn(__MODULE__, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end)
  end

  def temperature_of(location) do
    url()
    |> HTTPoison.get([], query_params(location))
    |> parse_response
    |> case do
      {:ok, temp} ->
        "#{location}: #{temp}°C"
      :error ->
        "#{location} not found."
    end
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
