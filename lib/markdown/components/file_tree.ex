defmodule Dieman.Markdown.Components.FileTree do
  @moduledoc """
  Processes file tree syntax into styled directory structures.

  ## Example

      ::tree
      src/
        components/
          Button.tsx
      ::

  With optional title:

      ::tree[Project Structure]
      src/
        components/
      ::

  Renders as an interactive file tree with appropriate icons.
  """

  alias Dieman.Assets

  # File type colors
  @colors %{
    elixir: "#9580FF",
    js: "#F7DF1E",
    config: "#6A9955",
    markdown: "#519ABA",
    css: "#56B6C2",
    html: "#E34C26"
  }

  @doc """
  Replaces `::tree...::` blocks with styled file tree HTML.
  Must be called BEFORE markdown processing to preserve whitespace.
  """
  def process(markdown) do
    Regex.replace(~r/::tree(?:\[([^\]]*)\])?\n([\s\S]*?)\n::/, markdown, fn _, title, content ->
      tree_html =
        content
        |> String.split("\n")
        |> Enum.map_join("\n", &parse_line/1)

      title_html =
        if title && title != "", do: ~s(<span class="file-tree-title">#{title}</span>), else: ""

      """
      <div class="file-tree">
      #{title_html}
      #{tree_html}
      </div>
      """
    end)
  end

  defp parse_line(line) do
    indent = div(String.length(line) - String.length(String.trim_leading(line)), 2)
    name = String.trim(line)

    cond do
      name == "" ->
        ""

      String.ends_with?(name, "/") ->
        dir_name = String.trim_trailing(name, "/")

        ~s(<div class="tree-item tree-dir" style="--indent: #{indent}"><span class="tree-icon">#{Assets.icon(:folder_open)}</span><span>#{dir_name}</span></div>)

      true ->
        {icon, color} = file_icon(name)

        ~s(<div class="tree-item tree-file" style="--indent: #{indent}; --file-color: #{color}"><span class="tree-icon">#{icon}</span><span>#{name}</span></div>)
    end
  end

  defp file_icon(filename) do
    icon = Assets.icon(:file_document)

    case Path.extname(filename) do
      e when e in [".ex", ".exs"] -> {icon, @colors.elixir}
      e when e in [".js", ".jsx", ".ts", ".tsx"] -> {icon, @colors.js}
      e when e in [".json", ".yaml", ".yml", ".toml"] -> {icon, @colors.config}
      e when e in [".md", ".mdx"] -> {icon, @colors.markdown}
      e when e in [".css", ".scss", ".sass"] -> {icon, @colors.css}
      e when e in [".html", ".eex", ".heex"] -> {icon, @colors.html}
      _ -> {icon, "currentColor"}
    end
  end
end
