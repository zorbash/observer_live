defmodule LiveViewExamples.Tabs.Network do
  import LiveViewExamples.Format

  alias LiveViewExamples.Tabs.Home

  @top_attributes [:recv_cnt, :send_cnt]

  def collect(%{stats: %{io: io_stats, gc: _}, settings: _} = state) do
    rendered_top = render_port_top(port_top(state))

    put_in(state, [:stats, :io], Home.io_stats(io_stats))
    |> put_in([:stats, :port_top], rendered_top)
  end

  def port_top(%{settings: %{
    interval: interval,
    top_ports_limit: top_ports_limit,
    top_ports_attribute: attribute,
    top_order: order
  }}) when attribute in @top_attributes do
    ports = case order do
      "desc" -> :recon.inet_count(attribute, top_ports_limit)
      "asc" -> :recon.inet_window(attribute, top_ports_limit, interval)
    end

    for {port, stat, _info} <- ports do
      %{
        port: port,
        info: :recon.port_info(port),
        stat: inspect(stat),
        remote_ip: remote_ip(port)
      }
    end
  end

  def render_port_top(top) do
    # Sad panda
    for {%{
      port: port,
      stat: _stat,
      info: info,
      remote_ip: remote_ip},
      i} <- Enum.with_index(top) do
      """
      <tr>
      <td>#{i + 1}</td>
      <td class="underline">#{inspect(port)}</td>
      <td>#{info[:type][:statistics][:recv_cnt]}</td>
      <td>#{info[:type][:statistics][:send_cnt]}</td>
      <td>#{number_to_human_size(info[:io][:output])}</td>
      <td>#{number_to_human_size(info[:io][:input])}</td>
      <td>#{info[:memory_used][:queue_size]}</td>
      <td>#{number_to_human_size(info[:memory_used][:memory])}</td>
      <td>#{remote_ip}</td>
      </tr>
      """
    end
  end

  def remote_ip(port) do
    case :inet.peername(port) do
      {:ok, {addr, p}} -> "#{:erlang.tuple_to_list(addr) |> Enum.join(".")}:#{inspect p}"
      {:error, error} -> :inet.format_error(error)
    end
  end
end
