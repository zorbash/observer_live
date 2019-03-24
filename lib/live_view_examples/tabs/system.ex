defmodule LiveViewExamples.Tabs.System do
  alias LiveViewExamples.Tabs.Home

  def collect(%{stats: stats, settings: _settings} = state) do
    put_in(state[:stats], Map.merge(stats, Home.base_stats()))
    |> put_in([:stats, :mem_stats], Home.mem_stats())
  end
end
