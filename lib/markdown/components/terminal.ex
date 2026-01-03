defmodule Dieman.Markdown.Components.Terminal do
  @moduledoc """
  Processes terminal/command output blocks with color support.

  ## Example

      ::terminal
      $ mix deps.get
      Resolving dependencies...
      {green:All dependencies installed!}
      {red:** (Mix) Could not find task}
      {#ff8800:Custom hex color}
      ::

  Supports:
  - Prompts: $ > ❯
  - Named colors: red, green, blue, yellow, orange, purple, cyan, white, gray
  - Hex colors: {#ff0000:text}
  - RGB colors: {rgb(255,0,0):text}
  """

  @named_colors %{
    "red" => "var(--red)",
    "green" => "var(--green)",
    "blue" => "var(--blue)",
    "yellow" => "var(--yellow)",
    "orange" => "var(--orange)",
    "purple" => "var(--purple)",
    "cyan" => "#56b6c2",
    "white" => "var(--fg)",
    "gray" => "var(--fg-muted)",
    "grey" => "var(--fg-muted)"
  }

  def process(markdown) do
    Regex.replace(~r/::terminal\n([\s\S]*?)\n::/, markdown, fn _, content ->
      lines =
        content
        |> String.trim()
        |> String.split("\n")
        |> Enum.map_join("\n", &format_line/1)

      """
      <div class="terminal">
      <div class="terminal-header">
      <span class="terminal-dot"></span>
      <span class="terminal-dot"></span>
      <span class="terminal-dot"></span>
      </div>
      <pre class="terminal-content">#{lines}</pre>
      </div>
      """
    end)
  end

  defp format_line(line) do
    cond do
      String.starts_with?(line, "$ ") ->
        command = String.trim_leading(line, "$ ")

        ~s(<span class="terminal-prompt">❯</span> <span class="terminal-command">#{process_colors(command)}</span>)

      String.starts_with?(line, "> ") ->
        command = String.trim_leading(line, "> ")

        ~s(<span class="terminal-prompt">❯</span> <span class="terminal-command">#{process_colors(command)}</span>)

      String.starts_with?(line, "❯ ") ->
        command = String.trim_leading(line, "❯ ")

        ~s(<span class="terminal-prompt">❯</span> <span class="terminal-command">#{process_colors(command)}</span>)

      true ->
        ~s(<span class="terminal-output">#{process_colors(line)}</span>)
    end
  end

  defp process_colors(text) do
    # Match {color:text} patterns
    Regex.replace(~r/\{([^}:]+):([^}]*)\}/, text, fn _, color, content ->
      css_color = resolve_color(color)
      ~s(<span style="color: #{css_color}">#{escape_html(content)}</span>)
    end)
    |> then(fn processed ->
      # Escape any remaining unprocessed text parts
      if processed == text do
        escape_html(text)
      else
        processed
      end
    end)
  end

  defp resolve_color(color) do
    color = String.trim(color) |> String.downcase()

    cond do
      # Named color
      Map.has_key?(@named_colors, color) ->
        @named_colors[color]

      # Hex color
      String.starts_with?(color, "#") ->
        color

      # RGB color
      String.starts_with?(color, "rgb") ->
        color

      # Default to white
      true ->
        "var(--fg)"
    end
  end

  defp escape_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
