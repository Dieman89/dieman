defmodule Dieman.Markdown.Components.Mermaid do
  @moduledoc """
  Renders Mermaid diagrams from fenced code blocks.

  ## Example

      ```mermaid
      graph LR
        A[Start] --> B{Decision}
        B -->|Yes| C[OK]
        B -->|No| D[Cancel]
      ```
  """

  def process(markdown) when is_binary(markdown) do
    Regex.replace(~r/```mermaid\n([\s\S]*?)```/, markdown, fn _, content ->
      encoded = content |> String.trim() |> Base.encode64()
      "<!--mermaid:#{encoded}-->"
    end)
  end

  def process(markdown), do: markdown

  def post_process(html) when is_binary(html) do
    Regex.replace(~r/<!--mermaid:([^-]+)-->/, html, fn _, encoded ->
      content = Base.decode64!(encoded)
      ~s(<div class="mermaid">#{content}</div>)
    end)
  end

  def post_process(html), do: html
end
