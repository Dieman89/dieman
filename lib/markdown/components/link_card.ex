defmodule Dieman.Markdown.Components.LinkCard do
  @moduledoc """
  Processes link card components for rich link previews.

  ## Example

  Single link card:

      ::link{https://github.com/elixir-lang/elixir}

  With optional title:

      ::link{https://github.com/elixir-lang/elixir|Elixir Language}

  Grouped links (use generic ::grid wrapper):

      ::grid
      ::link{https://github.com/elixir-lang/elixir|Elixir}
      ::link{https://hexdocs.pm/phoenix|Phoenix}
      ::
  """

  alias Dieman.Assets

  def process(html) do
    Regex.replace(~r/::link\{([^}|]+)(?:\|([^}]*))?\}/, html, fn _, url, title ->
      display_title = if title && title != "", do: title, else: extract_title(url)
      domain = extract_domain(url)
      icon = domain_icon(domain)

      """
      <a href="#{url}" class="link-card" target="_blank" rel="noopener noreferrer">
      <span class="link-card-icon">#{icon}</span>
      <span class="link-card-content">
      <span class="link-card-title">#{display_title}</span>
      <span class="link-card-url">#{domain}</span>
      </span>
      <span class="link-card-arrow">→</span>
      </a>
      """
    end)
  end

  defp extract_title(url) do
    url
    |> String.replace(~r{^https?://}, "")
    |> String.replace(~r{/$}, "")
    |> String.split("/")
    |> Enum.take(-2)
    |> Enum.join("/")
  end

  defp extract_domain(url) do
    url
    |> String.replace(~r{^https?://}, "")
    |> String.split("/")
    |> List.first()
  end

  defp domain_icon(domain) do
    cond do
      String.contains?(domain, "github.com") ->
        Assets.icon(:github)

      String.contains?(domain, "gitlab.com") ->
        Assets.icon(:gitlab)

      String.contains?(domain, "youtube.com") ->
        Assets.icon(:youtube)

      String.contains?(domain, "twitter.com") or String.contains?(domain, "x.com") ->
        Assets.icon(:twitter)

      true ->
        Assets.icon(:link)
    end
  end
end
