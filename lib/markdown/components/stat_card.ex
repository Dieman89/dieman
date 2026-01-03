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
  Replaces `::stat[value]{label}` patterns with styled stat cards.
  """
  def process(html) do
    Regex.replace(~r/::stat\[([^\]]+)\]\{([^}]+)\}/, html, fn _, value, label ->
      """
      <div class="stat-card">
        <span class="stat-value">#{String.trim(value)}</span>
        <span class="stat-label">#{String.trim(label)}</span>
      </div>
      """
    end)
  end
end
