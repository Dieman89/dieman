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

  defp icon_for("note"), do: info_icon()
  defp icon_for("info"), do: info_icon()
  defp icon_for("warning"), do: warning_icon()
  defp icon_for("tip"), do: tip_icon()
  defp icon_for(_), do: info_icon()

  defp info_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z"/></svg>)
  end

  defp warning_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575ZM8 5a.75.75 0 0 0-.75.75v2.5a.75.75 0 0 0 1.5 0v-2.5A.75.75 0 0 0 8 5Zm1 6a1 1 0 1 0-2 0 1 1 0 0 0 2 0Z"/></svg>)
  end

  defp tip_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M8 1.5c-2.363 0-4 1.69-4 3.75 0 .984.424 1.625.984 2.304l.214.253c.223.264.47.556.673.848.284.411.537.896.621 1.49a.75.75 0 0 1-1.484.211c-.04-.282-.163-.547-.37-.847a8.456 8.456 0 0 0-.542-.68c-.084-.1-.173-.205-.268-.32C3.201 7.75 2.5 6.766 2.5 5.25 2.5 2.31 4.863 0 8 0s5.5 2.31 5.5 5.25c0 1.516-.701 2.5-1.328 3.259-.095.115-.184.22-.268.319-.207.245-.383.453-.541.681-.208.3-.33.565-.37.847a.751.751 0 0 1-1.485-.212c.084-.593.337-1.078.621-1.489.203-.292.45-.584.673-.848.075-.088.147-.173.213-.253.561-.679.985-1.32.985-2.304 0-2.06-1.637-3.75-4-3.75ZM5.75 12h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1 0-1.5ZM6 15.25a.75.75 0 0 1 .75-.75h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1-.75-.75Z"/></svg>)
  end
end
