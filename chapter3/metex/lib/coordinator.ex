defmodule Metex.Coordinator do
  def loop(results \\ [], expected_num_results)  do
    receive do
      {:ok, result} ->
        results = [result | results]
        if (length(results) == expected_num_results) do
          send self(), :exit
        end
        loop(results, expected_num_results)
      :exit ->
        IO.puts(results |> Enum.sort |> Enum.join(", "))
      _ ->
        IO.puts "fucked up"
        loop(results, expected_num_results)
    end
  end
end
