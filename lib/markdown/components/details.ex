defmodule Dieman.Markdown.Components.Details do
  @moduledoc """
  Processes collapsible/details blocks.

  Supports markdown formatting inside, including badges.

  ## Example

      ::details[Show more]
      Hidden content here that can be expanded.

      Supports **markdown** and badges: ::badge[Elixir]{purple}
      ::
  """

  def pre_process(markdown) do
    Regex.replace(~r/::details\[([^\]]*)\]\n([\s\S]*?)\n::/, markdown, fn _, title, content ->
      "<!--details:#{title}-->\n#{String.trim(content)}\n<!--/details-->"
    end)
  end

  def post_process(html) do
    Regex.replace(~r/<!--details:([^>]*)-->([\s\S]*?)<!--\/details-->/, html, fn _,
                                                                                 title,
                                                                                 content ->
      """
      <details class="collapsible">
      <summary>#{title}</summary>
      <div class="collapsible-content">#{String.trim(content)}</div>
      </details>
      """
    end)
  end
end
