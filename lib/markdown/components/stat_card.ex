defmodule Dieman.Markdown.Components.StatCard do
  @moduledoc """
  Processes stat card components for displaying metrics.

  ## Example

  Single stats (inline):

      ::stat[99.9%]{Uptime}

  Grouped stats (use generic ::grid wrapper):

      ::grid
      ::stat[99.9%]{Uptime}
      ::stat[1.2M]{Downloads}
      ::stat[<50ms]{Response Time}
      ::

  Creates styled cards showing metric values with labels.
  """

  @doc """
  Replaces `::stat[value]{label}` or `::stat[value]{label|color}` patterns with styled stat cards.
  """
  def process(html) do
    Regex.replace(~r/::stat\[([^\]]+)\]\{([^}]+)\}/, html, fn _, value, label_part ->
      {label, color_class} = parse_label(label_part)

      """
      <div class="stat-card#{color_class}">
        <span class="stat-value">#{String.trim(value)}</span>
        <span class="stat-label">#{String.trim(label)}</span>
      </div>
      """
    end)
  end

  defp parse_label(label_part) do
    case String.split(label_part, "|", parts: 2) do
      [label, color] -> {label, " stat-#{String.trim(color)}"}
      [label] -> {label, ""}
    end
  end
end
