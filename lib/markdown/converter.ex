defmodule Dieman.Markdown.Converter do
  @moduledoc """
  Custom markdown converter with shortcode support for Tableau.

  ## Supported Components

  - `[[Key+Key]]` - Keyboard shortcuts
  - `::youtube{id}` - YouTube embeds
  - `::figure{src|alt|caption}` - Images with captions
  - `::tree...::` - File trees
  - `::tabs...::` - Code tabs with language switcher
  - `::compare...::` - Comparison tables
  - `::note/warning/tip...::` - Callout boxes
  - `::details[title]...::` - Collapsible sections
  - `::terminal...::` - Terminal output
  - `::quote[author]...::` - Quotes with attribution
  - `::diff...::` - Diff blocks
  - `::badge[text]{color}` - Inline badges
  - `::link{url|title}` - Link cards
  """

  alias Dieman.Markdown.Components.{
    Badge,
    Callout,
    CodeTabs,
    Comparison,
    Details,
    Diff,
    Figure,
    FileTree,
    Keyboard,
    LinkCard,
    Quote,
    Terminal,
    Youtube
  }

  @doc """
  Converts markdown content to HTML with shortcode processing.
  """
  def convert(_filepath, _front_matter, body, %{site: %{config: config}}) do
    body
    # Pre-markdown processing (preserves raw content)
    |> CodeTabs.process()
    |> FileTree.process()
    |> Terminal.process()
    |> Diff.process()
    |> LinkCard.process()
    |> Comparison.pre_process()
    |> Callout.pre_process()
    |> Details.pre_process()
    |> Quote.pre_process()
    # Markdown to HTML
    |> MDEx.to_html!(config.markdown[:mdex])
    # Post-markdown processing
    |> Comparison.post_process()
    |> Callout.post_process()
    |> Details.post_process()
    |> Quote.post_process()
    |> Keyboard.process()
    |> Youtube.process()
    |> Figure.process()
    |> Badge.process()
  end
end
