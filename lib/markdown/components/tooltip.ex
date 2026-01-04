defmodule Dieman.Markdown.Components.Tooltip do
  @moduledoc """
  Inline hover tooltips for definitions.

  ## Example

      ::def[IAM]{Identity and Access Management}
      ::def[K8s]{Kubernetes container orchestration}
  """

  def process(html) when is_binary(html) do
    Regex.replace(~r/::def\[([^\]]+)\]\{([^}]+)\}/, html, fn _, term, definition ->
      ~s(<span class="tooltip" data-tip="#{definition}">#{term}</span>)
    end)
  end

  def process(html), do: html
end
