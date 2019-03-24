defmodule LiveViewExamplesWeb.ObserverLive do
  use Phoenix.LiveView

  alias LiveViewExamplesWeb.PageView, as: View
  alias LiveViewExamplesWeb.Layout
  alias LiveViewExamples.Tabs.{Home, Network, System}

  @initial_state %{
    settings: %{
      interval: 1000,
      view: :home,
      top_processes_limit: 31,
      top_ports_limit: 31,
      top_ports_attribute: :recv_cnt,
      top_attribute: :memory,
      top_order: "desc"
    },
    stats: %{
      io: %{
        input: 0,
        output: 0
      },
      gc: %{
        gcs: 0,
        words: 0
      },
      schedulers: %{
        wall: nil,
        formatted: nil
      },
      process_top: [],
      port_top: []
    },
    system_info: %{}
  }

  @views [:home, :network, :system, :ets, :mnesia, :app]

  def render(view, assigns) when view in @views do
    View.render("#{view}.html", assigns)
  end

  def render(assigns), do: ~L"<%= Layout.render(assigns) %>"

  def mount(_session, %{assigns: _} = socket) do
    tref = if connected?(socket) do
             schedule_refresh(@initial_state[:settings][:interval], %{tref: nil})
           end

    :erlang.system_flag(:scheduler_wall_time, true)
    {:ok, initial_state(assign(socket, :tref, tref))}
  end

  def initial_state(socket) do
    socket
    |> assign(settings: @initial_state[:settings])
    |> assign(system_info: Home.system_info)
    |> assign(stats: collect(@initial_state, :home)[:stats])
  end

  def schedule_refresh(interval, %{tref: tref}) do
    if tref, do: :timer.cancel(tref)

    case :timer.send_interval(interval, self(), :refresh) do
      {:ok, tref} -> tref
      _ -> nil
    end
  end

  def collect(state, :home), do: Home.collect(state)
  def collect(%{stats: %{io: _io_stats}} = state, :network) do
    Map.merge(state, Network.collect(state))
  end
  def collect(%{stats: _} = state, :system) do
    Map.merge(state, System.collect(state))
  end
  def collect(state, _), do: state

  def handle_info(:refresh, %{assigns: %{settings: %{view: view}} = state} = socket) do
    {:noreply, update(socket, :stats, &Map.merge(&1, collect(state, view)[:stats]))}
  end

  def handle_event("render_" <> view, _path, socket) do
    send self(), :refresh

    {:noreply, update(socket, :settings, &(put_in(&1[:view], String.to_existing_atom(view))))}
  end

  def handle_event("interval_increase", _path, %{assigns: %{tref: _} = tref} = socket) do
    socket = update(socket, :settings, &(put_in(&1[:interval], &1[:interval] + 50)))
    socket = update(socket, :tref, fn _ -> schedule_refresh(socket.assigns.settings.interval, tref) end)

    {:noreply, socket}
  end

  def handle_event("interval_decrease", _path, %{assigns: %{settings: %{interval: interval}}} = socket)
  when interval <= 200,
  do: {:noreply, socket}

  def handle_event("interval_decrease", _path, %{assigns: %{tref: _} = tref} = socket) do
    socket = update(socket, :settings, &(put_in(&1[:interval], &1[:interval] - 50)))
    socket = update(socket, :tref, fn _ -> schedule_refresh(socket.assigns.settings.interval, tref) end)

    {:noreply, socket}
  end

  def handle_event(
    "set_top_attr_" <> current_attr,
    _path,
    %{assigns: %{settings: %{top_attribute: attr, top_order: order}}} = socket) do
    case {String.to_existing_atom(current_attr), attr, order} do
      {attribute, attribute, "desc"} ->
        {:noreply, update(socket, :settings, &(put_in(&1[:top_order], "asc")))}
      {attribute, attribute, "asc"} ->
        {:noreply, update(socket, :settings, &(put_in(&1[:top_order], "desc")))}
      _ ->
        {:noreply, update(socket, :settings, &(put_in(&1[:top_attribute], current_attr |> String.to_existing_atom)))}
    end
  end

  def handle_event(
    "set_ports_top_attr_" <> current_attr,
    _path,
    %{assigns: %{settings: %{top_ports_attribute: attr, top_order: order}}} = socket) do
    case {String.to_existing_atom(current_attr), attr, order} do
      {attribute, attribute, "desc"} ->
        {:noreply, update(socket, :settings, &(put_in(&1[:top_order], "asc")))}
      {attribute, attribute, "asc"} ->
        {:noreply, update(socket, :settings, &(put_in(&1[:top_order], "desc")))}
      _ ->
        {:noreply, update(socket, :settings, &(put_in(&1[:top_ports_attribute], current_attr |> String.to_existing_atom)))}
    end
  end

  def handle_event(_event, _path, socket) do
    {:noreply, socket}
  end
end
