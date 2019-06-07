defmodule LiveViewExamples.Tabs.System do
  import LiveViewExamples.Format

  alias LiveViewExamples.Tabs.Home

  @allocators [
    :binary_alloc,
    :driver_alloc,
    :eheap_alloc,
    :ets_alloc,
    :fix_alloc,
    :ll_alloc,
    :sl_alloc,
    :std_alloc,
    :temp_alloc
  ]

  def collect(%{stats: stats, settings: _settings} = state) do
    put_in(state[:stats], Map.merge(stats, Home.base_stats()))
    |> put_in([:stats, :mem_stats], Home.mem_stats())
    |> put_in([:stats, :allocators], rendered_allocators())
  end

  defp rendered_allocators do
    # This is due to an "Uncaught TypeError: Cannot create property 'dynamics' on string"
    # when trying to use a template

    for {alloc, stats} <- allocators() do
     """
     <tr>
     <td class="bold">#{alloc}</td>
     <td>#{stats[:current_multi]}</td>
     <td>#{stats[:max_multi]}</td>
     <td>#{stats[:current_single]}</td>
     <td>#{stats[:max_single]}</td>
     </tr>
     """
    end
  end

  defp allocators do
    current = :recon_alloc.average_block_sizes(:current)
    max = :recon_alloc.average_block_sizes(:max)

    for alloc <- @allocators, into: %{} do
      {alloc, %{
        current_single: number_to_human_size(current[alloc][:sbcs]),
        current_multi: number_to_human_size(current[alloc][:mbcs]),
        max_single: number_to_human_size(max[alloc][:sbcs]),
        max_multi: number_to_human_size(max[alloc][:mbcs])
      }}
    end
  end
end
