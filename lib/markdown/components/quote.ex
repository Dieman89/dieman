defmodule Dieman.Markdown.Components.Quote do
  @moduledoc """
  Processes quote blocks with attribution.

  ## Example

      ::quote[Rich Hickey]
      Simple made easy.
      ::
  """

  def pre_process(markdown) do
    Regex.replace(~r/::quote\[([^\]]*)\]\n([\s\S]*?)\n::/, markdown, fn _, author, content ->
      "<!--quote:#{author}-->\n#{String.trim(content)}\n<!--/quote-->"
    end)
  end

  def post_process(html) do
    Regex.replace(~r/<!--quote:([^>]*)-->([\s\S]*?)<!--\/quote-->/, html, fn _, author, content ->
      """
      <figure class="styled-quote">
      <blockquote>#{String.trim(content)}</blockquote>
      <figcaption>#{author}</figcaption>
      </figure>
      """
    end)
  end
end
