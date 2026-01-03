defmodule Dieman.Markdown.Components.Keyboard do
  @moduledoc """
  Processes keyboard shortcut syntax `[[Key+Key]]` into styled `<kbd>` elements.

  ## Example

      Press [[Cmd+K]] to search or [[Ctrl+Shift+P]] for commands.

  Becomes:

      Press <span class="kbd-combo"><kbd>Cmd</kbd><span class="kbd-plus">+</span><kbd>K</kbd></span>
  """

  @doc """
  Replaces `[[Key+Key]]` patterns with styled kbd elements.
  """
  def process(html) do
    Regex.replace(~r/\[\[([^\]]+)\]\]/, html, fn _, keys ->
      keys
      |> String.split("+")
      |> Enum.map_join("<span class=\"kbd-plus\">+</span>", &"<kbd>#{String.trim(&1)}</kbd>")
      |> then(&"<span class=\"kbd-combo\">#{&1}</span>")
    end)
  end
end
