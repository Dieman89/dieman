defmodule Dieman.Markdown.Components.SmallCaps do
  @moduledoc """
  Small caps for abbreviations and acronyms.

  Usage: ::sc[HTML] or ::sc[CSS]
  """

  def process(html) when is_binary(html) do
    Regex.replace(~r/::sc\[([^\]]+)\]/, html, fn _, text ->
      ~s(<span class="small-caps">#{text}</span>)
    end)
  end

  def process(html), do: html
end
