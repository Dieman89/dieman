defmodule Dieman.Markdown.Components.Badge do
  @moduledoc """
  Processes inline badge/label components.

  ## Example

      ::badge[v2.0.0]
      ::badge[deprecated]{red}
      ::badge[new]{green}
  """

  def process(html) do
    # Match ::badge[text]{color} or ::badge[text]
    Regex.replace(~r/::badge\[([^\]]*)\](?:\{(\w+)\})?/, html, fn _, text, color ->
      color_class = if color && color != "", do: " badge-#{color}", else: ""
      ~s(<span class="badge#{color_class}">#{text}</span>)
    end)
  end
end
