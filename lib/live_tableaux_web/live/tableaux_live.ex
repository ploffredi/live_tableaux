defmodule LiveTableauxWeb.TableauxLive do
  use LiveTableauxWeb, :live_view

  @samples [
    "p|q,q|-q",
    "|-(p∨(q∧r))→((p∨q)∧(p∨r))",
    "p∨q|-(p∨(q∧r))→((p∨q)∧(p∨r))",
  ]
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, sequent: "", samples: @samples)}
  end

  @impl true
  def handle_event("suggest", %{"q" => sequent}, socket) do
    {:noreply, assign(socket, sequent: sequent)}
  end

  @impl true
  def handle_event("add_not", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "¬")}
  end

  @impl true
  def handle_event("add_and", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "∧")}
  end

  @impl true
  def handle_event("add_or", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "∨")}
  end

  @impl true
  def handle_event("add_implies", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "→")}
  end

  @impl true
  def handle_event("expand", %{"q" => sequent}, socket) do
    {:noreply,
     push_event(socket, "updateResultTree", Tableaux.expand_sequent(sequent) |> BinTree.to_map())}
  end

  @impl true
  def handle_event("sample_selected", %{"sample" => sequent}, socket) do
    socket=assign(socket, sequent: sequent)
    {:noreply,
     push_event(socket, "updateResultTree", Tableaux.expand_sequent(sequent) |> BinTree.to_map())}
  end
end
