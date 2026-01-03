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

        ~s(<div class="tree-item tree-dir" style="--indent: #{indent}"><span class="tree-icon">#{folder_icon()}</span><span>#{dir_name}</span></div>)

      true ->
        icon = file_icon(name)

        ~s(<div class="tree-item tree-file" style="--indent: #{indent}"><span class="tree-icon">#{icon}</span><span>#{name}</span></div>)
    end
  end

  defp folder_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M1.75 1A1.75 1.75 0 0 0 0 2.75v10.5C0 14.216.784 15 1.75 15h12.5A1.75 1.75 0 0 0 16 13.25v-8.5A1.75 1.75 0 0 0 14.25 3H7.5a.25.25 0 0 1-.2-.1l-.9-1.2C6.07 1.26 5.55 1 5 1H1.75Z"/></svg>)
  end

  defp file_icon(filename) do
    case Path.extname(filename) do
      e when e in [".ex", ".exs"] -> elixir_icon()
      e when e in [".js", ".jsx", ".ts", ".tsx"] -> js_icon()
      e when e in [".json", ".yaml", ".yml", ".toml"] -> config_icon()
      e when e in [".md", ".mdx"] -> markdown_icon()
      e when e in [".css", ".scss", ".sass"] -> css_icon()
      e when e in [".html", ".eex", ".heex"] -> html_icon()
      _ -> default_icon()
    end
  end

  defp default_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)
  end

  defp elixir_icon do
    ~s(<svg viewBox="0 0 16 16" fill="#9580FF"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)
  end

  defp js_icon do
    ~s(<svg viewBox="0 0 16 16" fill="#F7DF1E"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)
  end

  defp config_icon do
    ~s(<svg viewBox="0 0 16 16" fill="#6A9955"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)
  end

  defp markdown_icon do
    ~s(<svg viewBox="0 0 16 16" fill="#519ABA"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)
  end

  defp css_icon do
    ~s(<svg viewBox="0 0 16 16" fill="#56B6C2"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)
  end

  defp html_icon do
    ~s(<svg viewBox="0 0 16 16" fill="#E34C26"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)
  end
end
