defmodule Dieman.Markdown.Components.Divider do
  @moduledoc """
  Horizontal rule with centered text.

  Usage: ::divider[Section Break]
  """

  def process(html) when is_binary(html) do
    Regex.replace(~r/::divider\[([^\]]+)\]/, html, fn _, text ->
      ~s(<div class="divider"><span>#{text}</span></div>)
    end)
  end

  def process(html), do: html
end
