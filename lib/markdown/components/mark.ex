defmodule Dieman.Markdown.Components.Mark do
  @moduledoc """
  Highlight/marker for important text with hand-drawn SVG effect.

  Usage: ::mark[important text]
  Optional color: ::mark[text]{yellow} or ::mark[text]{orange}
  """

  @svg_marker """
  <svg class="marker-svg" viewBox="0 0 200 60" preserveAspectRatio="none">
    <rect x="0" y="0" width="200" height="60" rx="5" ry="5"/>
  </svg>
  """

  def process(html) when is_binary(html) do
    # With color
    html =
      Regex.replace(~r/::mark\[([^\]]+)\]\{([^}]+)\}/, html, fn _, text, color ->
        ~s(<mark class="marker marker-#{color}">#{@svg_marker}#{text}</mark>)
      end)

    # Without color (default yellow)
    Regex.replace(~r/::mark\[([^\]]+)\]/, html, fn _, text ->
      ~s(<mark class="marker">#{@svg_marker}#{text}</mark>)
    end)
  end

  def process(html), do: html
end
