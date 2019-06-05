defmodule LiveViewExamples.Tabs.Home do
  import LiveViewExamples.Format

  @top_attributes [:memory, :reductions]

  def collect(%{
    stats: %{
      io: io_stats,
      gc: gc_stats,
      schedulers: schedulers
    } = stats,
    settings: _
  } = state) do
    put_in(state[:stats], Map.merge(stats, base_stats()))
    |> put_in([:stats, :mem_stats], mem_stats())
    |> put_in([:stats, :reds_stats], reds_stats())
    |> put_in([:stats, :io], io_stats(io_stats))
    |> put_in([:stats, :runq_stats], runq_stats())
    |> put_in([:stats, :gc], gc_stats(gc_stats))
    |> put_in([:stats, :schedulers], schedulers_stats(schedulers))
    |> put_in([:stats, :process_top], process_top(state))
    |> put_in([:stats, :allocators], [])
  end

  def system_info do
    schedulers_online = :erlang.system_info(:schedulers_online)
    multi_scheduling = :erlang.system_info(:multi_scheduling)
    schedulers_available = case multi_scheduling do
                             :enabled -> schedulers_online
                             _ -> 1
                           end

    %{
      system_version: :erlang.system_info(:system_version),
      version: :erlang.system_info(:version),
      proc_limit: :erlang.system_info(:process_limit),
      port_limit: :erlang.system_info(:port_limit),
      atom_limit: :erlang.system_info(:atom_limit),
      smp_support: :erlang.system_info(:smp_support),
      multi_scheduling: multi_scheduling,
      logical_processors: :erlang.system_info(:logical_processors),
      logical_processors_online: :erlang.system_info(:logical_processors_online),
      logical_processors_available: :erlang.system_info(:logical_processors_available),
      schedulers: :erlang.system_info(:schedulers),
      schedulers_online: schedulers_online,
      schedulers_available: schedulers_available,
      otp_release: :erlang.system_info(:otp_release),
      system_architecture: :erlang.system_info(:system_architecture),
      kernel_poll: :erlang.system_info(:kernel_poll),
      threads: :erlang.system_info(:threads),
      thread_pool_size: :erlang.system_info(:thread_pool_size),
      wordsize_internal: :erlang.system_info({:wordsize, :internal}),
      wordsize_external: :erlang.system_info({:wordsize, :external})
    }
  end

  def base_stats do
    base_stats = %{
      proc_count: :erlang.system_info(:process_count),
      port_count: :erlang.system_info(:port_count),
      atom_count: :erlang.system_info(:atom_count),
      mem_allocated: :recon_alloc.memory(:allocated),
      mem_used: :recon_alloc.memory(:used)
    }

    unused_mem = base_stats[:mem_allocated] - base_stats[:mem_used]
    without_perc = put_in(base_stats[:mem_unused], number_to_human_size(unused_mem))
    |> put_in([:mem_allocated], number_to_human_size(base_stats[:mem_allocated]))
    |> put_in([:mem_used], number_to_human_size(base_stats[:mem_used]))

    without_perc
    |> put_in([:mem_used_perc], to_percentage(base_stats[:mem_used] / base_stats[:mem_allocated]))
    |> put_in([:mem_unused_perc], to_percentage(unused_mem / base_stats[:mem_allocated]))
  end

  def mem_stats do
    for {k, v} <- :erlang.memory, into: %{}, do: {k, number_to_human_size(v)}
  end

  def reds_stats do
    {_, reds} = :erlang.statistics(:reductions)

    reds
  end

  def io_stats(%{input: last_input, output: last_output}) do
    {{:input, total_input}, {:output, total_output}} = :erlang.statistics(:io)
    input = total_input - last_input
    output = total_output - last_output

    %{
      input: input,
      total_input_human: number_to_human_size(total_input),
      input_human: number_to_human_size(input),
      output: output,
      total_output_human: number_to_human_size(total_output),
      output_human: number_to_human_size(output)
    }
  end

  def runq_stats do
    %{
      run_queue: :erlang.statistics(:run_queue),
      error_logger_queue: error_logger_queue()
    }
  end

  defp error_logger_queue do
    case Process.whereis(:error_logger) do
      logger when is_pid(logger) ->
        {_, len} = Process.info(logger, :message_queue_len)
        len
      _ -> ?0
    end
  end

  def gc_stats(%{gcs: last_gcs, words: last_words}) do
    {gcs, words, _} = :erlang.statistics(:garbage_collection)

    %{
      gcs: gcs - last_gcs,
      words: words - last_words
    }
  end

  defp process_top(%{settings: %{
    interval: interval,
    top_processes_limit: top_processes_limit,
    top_attribute: attribute,
    top_order: order
  }}) when attribute in @top_attributes do
    procs = case order do
      "desc" -> :recon.proc_count(attribute, top_processes_limit)
      "asc" -> :recon.proc_window(attribute, top_processes_limit, interval)
    end

    for {pid, stat, info} <- procs do
      name = case info do
        [a, b, _] when is_atom(a) and is_tuple(b) -> a
        _ -> nil
      end

      [reductions: reds, message_queue_len: msq] =
        case Process.info(pid, [:reductions, :message_queue_len]) do
          nil -> [reductions: nil, message_queue_len: nil]
          info -> info
        end

      %{
        pid: pid,
        stat: format_stat(stat, attribute),
        name: name,
        reductions: reds,
        message_queue_len: msq,
        current_function: Access.get(info, :current_function),
        initial_call: Access.get(info, :initial_call)
      }
    end
  end

  defp schedulers_stats(%{wall: nil} = stats) do
    schedulers_stats(put_in(stats[:wall], :erlang.statistics(:scheduler_wall_time)))
  end

  defp schedulers_stats(%{wall: wall} = stats) do
    new_wall = :erlang.statistics(:scheduler_wall_time)
    diff = :recon_lib.scheduler_usage_diff(new_wall, wall)

    stats
    |> put_in([:wall], new_wall)
    |> put_in([:formatted], format_schedulers(diff))
  end

  defp format_schedulers(wall) do
    schedulers = length(wall)
    rows = round(schedulers / 4)

    wall
    |> Enum.map(fn {sched, v} -> {sched, Float.round(v * 100, 4)} end)
    |> Enum.group_by(fn
      {n, _} when rem(n, rows) == 0 -> rows
      {n, _} -> rem(n, rows)
    end)
  end

  defp format_stat(value, :memory), do: number_to_human_size(value)
  defp format_stat(value, _), do: value
end
