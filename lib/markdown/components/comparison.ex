defmodule Dieman.Markdown.Components.Comparison do
  @moduledoc """
  Processes comparison table syntax into styled tables with winner highlighting.

  ## Example

      ::compare[Build Performance]
      | Implementation | Time |
      |----------------|------|
      | Go | 5 seconds |
      | Scala | 51 seconds |
      ::

  The first data row is highlighted as the "winner" with green styling.
  """

  @doc """
  Pre-processes comparison markers before markdown conversion.
  Replaces `::compare[title]` with HTML comment marker, keeps table as markdown.
  """
  def pre_process(markdown) do
    Regex.replace(~r/::compare(?:\[([^\]]*)\])?\n([\s\S]*?)\n::/, markdown, fn _, title, content ->
      marker = if title && title != "", do: "<!--compare:#{title}-->", else: "<!--compare-->"
      "#{marker}\n#{String.trim(content)}"
    end)
  end

  @doc """
  Post-processes HTML after markdown conversion.
  Wraps tables preceded by compare markers in styled containers.
  """
  def post_process(html) do
    # Match marker followed by table
    Regex.replace(~r/<!--compare(?::([^>]*))?-->\s*(<table[\s\S]*?<\/table>)/, html, fn _,
                                                                                        title,
                                                                                        table ->
      title_html =
        if title && title != "", do: ~s(<span class="compare-title">#{title}</span>), else: ""

      """
      <div class="comparison-table">
      #{title_html}
      #{table}
      </div>
      """
    end)
  end
end
