defmodule Dieman.Markdown.Components.CodeTabs do
  @moduledoc """
  Processes code tabs showing the same example in multiple languages.

  ## Example

      ::tabs
      ```go[Go]
      func hello() {
          fmt.Println("Hello")
      }
      ```

      ```scala[Scala]
      def hello(): Unit = {
          println("Hello")
      }
      ```
      ::

  Renders as tabbed code blocks with language switcher.
  """

  alias Dieman.Content

  @doc """
  Replaces `::tabs...::` blocks with tabbed code interface.
  Must be called BEFORE markdown processing.
  """
  def process(markdown) do
    Regex.replace(~r/::tabs\n([\s\S]*?)\n::/, markdown, fn _, content ->
      tabs = parse_tabs(content)

      if Enum.empty?(tabs) do
        content
      else
        build_tabs_html(tabs)
      end
    end)
  end

  defp parse_tabs(content) do
    Regex.scan(~r/```(\w+)\[([^\]]+)\]\n([\s\S]*?)```/, content)
    |> Enum.map(fn [_, lang, label, code] ->
      %{lang: lang, label: label, code: String.trim(code)}
    end)
  end

  defp build_tabs_html(tabs) do
    tab_id = :erlang.unique_integer([:positive])

    tab_buttons =
      tabs
      |> Enum.with_index()
      |> Enum.map_join("", fn {tab, idx} ->
        active = if idx == 0, do: " active", else: ""

        ~s(<button class="code-tab#{active}" data-tab="#{tab_id}-#{idx}" data-lang="#{tab.lang}">#{tab.label}</button>)
      end)

    tab_panels =
      tabs
      |> Enum.with_index()
      |> Enum.map_join("", fn {tab, idx} ->
        active = if idx == 0, do: " active", else: ""
        highlighted = highlight_code(tab.code, tab.lang)

        ~s(<div class="code-panel#{active}" data-panel="#{tab_id}-#{idx}">#{highlighted}</div>)
      end)

    """
    <div class="code-tabs">
    <div class="code-tabs-header">#{tab_buttons}</div>
    <div class="code-tabs-content">#{tab_panels}</div>
    </div>
    """
  end

  defp highlight_code(code, lang) do
    Autumn.highlight!(code,
      language: lang,
      formatter: {:html_inline, theme: Content.syntax_theme()}
    )
  end
end
