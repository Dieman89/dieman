defmodule Dieman.Markdown.Components.Callout do
  @moduledoc """
  Processes callout/admonition blocks into styled boxes.

  ## Example

      ::note
      This is important information.
      ::

      ::warning
      Be careful with this approach.
      ::

      ::tip
      Pro tip: use caching for better performance.
      ::

  Supported types: note, warning, tip, info
  """

  alias Dieman.Assets

  @types ~w(note warning tip info)

  @doc """
  Pre-processes callout markers before markdown conversion.
  """
  def pre_process(markdown) do
    Regex.replace(~r/::(#{Enum.join(@types, "|")})\n([\s\S]*?)\n::/, markdown, fn _,
                                                                                  type,
                                                                                  content ->
      "<!--callout:#{type}-->\n#{String.trim(content)}\n<!--/callout-->"
    end)
  end

  @doc """
  Post-processes HTML after markdown conversion.
  Wraps content between callout markers in styled containers.
  """
  def post_process(html) do
    Regex.replace(~r/<!--callout:(\w+)-->([\s\S]*?)<!--\/callout-->/, html, fn _, type, content ->
      icon = icon_for(type)

      """
      <div class="callout callout-#{type}">
      <span class="callout-icon">#{icon}</span>
      <div class="callout-content">#{String.trim(content)}</div>
      </div>
      """
    end)
  end

  defp icon_for("note"), do: Assets.icon(:info)
  defp icon_for("info"), do: Assets.icon(:info)
  defp icon_for("warning"), do: Assets.icon(:warning)
  defp icon_for("tip"), do: Assets.icon(:lightbulb)
  defp icon_for(_), do: Assets.icon(:info)
end
