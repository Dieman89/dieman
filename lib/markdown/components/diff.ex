defmodule Dieman.Markdown.Components.Diff do
  @moduledoc """
  Processes diff blocks showing code changes.

  ## Example

      ::diff
      - const old = "value"
      + const new = "better"
        unchanged line
      ::
  """

  def process(markdown) do
    Regex.replace(~r/::diff\n([\s\S]*?)\n::/, markdown, fn _, content ->
      lines =
        content
        |> String.trim()
        |> String.split("\n")
        |> Enum.reject(&(&1 == ""))
        |> Enum.map_join("", &format_line/1)

      """
      <div class="diff-block">
      <pre class="diff-content">#{lines}</pre>
      </div>
      """
    end)
  end

  defp format_line(line) do
    cond do
      String.starts_with?(line, "+ ") ->
        content = String.trim_leading(line, "+ ")
        ~s(<span class="diff-add">#{escape_html(content)}</span>)

      String.starts_with?(line, "- ") ->
        content = String.trim_leading(line, "- ")
        ~s(<span class="diff-remove">#{escape_html(content)}</span>)

      String.starts_with?(line, "  ") ->
        content = String.slice(line, 2..-1//1)
        ~s(<span class="diff-context">#{escape_html(content)}</span>)

      true ->
        ~s(<span class="diff-context">#{escape_html(line)}</span>)
    end
  end

  defp escape_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
