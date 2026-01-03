defmodule Dieman.Markdown.Components.Grid do
  @moduledoc """
  Generic grid wrapper for any components.

  ## Examples

  Auto-sized grid (equal columns, full width):

      ::grid
      ::figure{/images/one.jpg|First}
      ::figure{/images/two.jpg|Second}
      ::

  With explicit column count:

      ::grid[3]
      ::stat[99%]{Uptime}
      ::stat[1M]{Users}
      ::stat[<50ms]{Latency}
      ::

  With percentage width:

      ::grid[60%]
      ::figure{/images/one.jpg|First}
      ::figure{/images/two.jpg|Second}
      ::
  """

  @doc """
  Pre-processes `::grid...::` blocks before markdown conversion.
  """
  def pre_process(markdown) when is_binary(markdown) do
    # With percentage width: ::grid[50%]
    markdown =
      Regex.replace(~r/::grid\[(\d+)%\]\n([\s\S]*?)\n::(?![a-z])/, markdown, fn _, pct, content ->
        joined = content |> String.trim() |> String.replace("\n", " ")
        "<!--grid-w#{pct}-start-->#{joined}<!--grid-w#{pct}-end-->"
      end)

    # With column count: ::grid[n]
    markdown =
      Regex.replace(~r/::grid\[(\d+)\]\n([\s\S]*?)\n::(?![a-z])/, markdown, fn _, cols, content ->
        joined = content |> String.trim() |> String.replace("\n", " ")
        "<!--grid-#{cols}-start-->#{joined}<!--grid-#{cols}-end-->"
      end)

    # Without options: ::grid
    Regex.replace(~r/::grid\n([\s\S]*?)\n::(?![a-z])/, markdown, fn _, content ->
      joined = content |> String.trim() |> String.replace("\n", " ")
      "<!--grid-start-->#{joined}<!--grid-end-->"
    end)
  end

  def pre_process(markdown), do: markdown

  @doc """
  Post-processes grid wrapper after markdown conversion.
  """
  def post_process(html) when is_binary(html) do
    # With percentage width
    html =
      Regex.replace(~r/<!--grid-w(\d+)-start-->/, html, fn _, pct ->
        ~s(<div class="grid" style="width: #{pct}%">)
      end)

    html = Regex.replace(~r/<!--grid-w(\d+)-end-->/, html, "</div>")

    # With column count
    html =
      Regex.replace(~r/<!--grid-(\d+)-start-->/, html, fn _, cols ->
        ~s(<div class="grid grid-#{cols}">)
      end)

    html = Regex.replace(~r/<!--grid-(\d+)-end-->/, html, "</div>")

    # Without options (auto)
    html
    |> String.replace("<!--grid-start-->", ~s(<div class="grid">))
    |> String.replace("<!--grid-end-->", "</div>")
  end

  def post_process(html), do: html
end
