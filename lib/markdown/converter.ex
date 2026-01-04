defmodule Dieman.Markdown.Converter do
  @moduledoc """
  Custom markdown converter with shortcode support for Tableau.

  ## Supported Components

  - `[[Key+Key]]` - Keyboard shortcuts
  - `::youtube{id}` - YouTube embeds
  - `::figure[align]{src|alt|caption}` - Images with captions (align: left/center/full)
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
  - `::timeline...::` - Chronological timeline
  - `::compare-images{before|after|labelBefore|labelAfter}` - Image comparison slider
  - `::stat[value]{label}` - Stats cards
  - `::grid...::` or `::grid[n]...::` - Generic grid wrapper for any components
  - `::def[term]{definition}` - Inline tooltip definitions
  - ` ```mermaid ``` ` - Mermaid diagrams (flowcharts, sequence diagrams)
  - `::gist{user/id}` - GitHub Gist embed
  - `::divider[text]` - Horizontal rule with centered text
  - `::mark[text]` or `::mark[text]{color}` - Highlight/marker
  - `::sc[TEXT]` - Small caps for abbreviations
  - `::tweet{id}` - Embed X/Twitter tweet
  """

  alias Dieman.Markdown.Components.{
    Badge,
    Callout,
    Center,
    CodeTabs,
    Comparison,
    Details,
    Diff,
    Divider,
    Figure,
    FileTree,
    Gist,
    Grid,
    ImageCompare,
    Keyboard,
    LinkCard,
    Mark,
    Mermaid,
    Quote,
    SmallCaps,
    StatCard,
    Steps,
    Terminal,
    Timeline,
    Tooltip,
    X,
    Youtube
  }

  @block_components ~w(center grid steps callout note warning tip details quote timeline stats links figures compare)

  @doc """
  Converts markdown content to HTML with shortcode processing.
  """
  def convert(filepath, _front_matter, body, %{site: %{config: config}}) do
    validate_closed_blocks(body, filepath)

    body
    # Pre-markdown processing (preserves raw content)
    |> CodeTabs.process()
    |> FileTree.process()
    |> Terminal.process()
    |> Diff.process()
    |> Mermaid.process()
    |> X.pre_process()
    |> Grid.pre_process()
    |> Center.pre_process()
    |> Steps.pre_process()
    |> Comparison.pre_process()
    |> Callout.pre_process()
    |> Details.pre_process()
    |> Quote.pre_process()
    |> Timeline.pre_process()
    # Markdown to HTML
    |> MDEx.to_html!(config.markdown[:mdex])
    # Post-markdown processing
    |> Mermaid.post_process()
    |> Grid.post_process()
    |> Center.post_process()
    |> Steps.post_process()
    |> Comparison.post_process()
    |> Callout.post_process()
    |> Details.post_process()
    |> Quote.post_process()
    |> Timeline.post_process()
    |> Keyboard.process()
    |> Youtube.process()
    |> Figure.process()
    |> ImageCompare.process()
    |> Badge.process()
    |> StatCard.process()
    |> LinkCard.process()
    |> Tooltip.process()
    |> Gist.process()
    |> Divider.process()
    |> Mark.process()
    |> SmallCaps.process()
    |> X.post_process()
  end

  defp validate_closed_blocks(body, filepath) do
    lines = String.split(body, "\n")

    Enum.reduce(lines, {[], 1}, fn line, {stack, line_num} ->
      cond do
        # Opening a block: ::component or ::component[...]
        Regex.match?(~r/^::(#{Enum.join(@block_components, "|")})(\[|$|\n)/, line) ->
          component = Regex.run(~r/^::(#{Enum.join(@block_components, "|")})/, line) |> List.last()
          {[{component, line_num} | stack], line_num + 1}

        # Closing a block: just ::
        Regex.match?(~r/^::$/, String.trim(line)) and stack != [] ->
          {tl(stack), line_num + 1}

        true ->
          {stack, line_num + 1}
      end
    end)
    |> case do
      {[], _} ->
        :ok

      {unclosed, _} ->
        errors =
          Enum.map_join(unclosed, "\n", fn {component, line} ->
            "  - ::#{component} at line #{line}"
          end)

        raise "Unclosed block(s) in #{filepath}:\n#{errors}"
    end
  end
end
