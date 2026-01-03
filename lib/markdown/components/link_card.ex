defmodule Dieman.Markdown.Components.LinkCard do
  @moduledoc """
  Processes link card components for rich link previews.

  ## Example

      ::link{https://github.com/elixir-lang/elixir}

  With optional title:

      ::link{https://github.com/elixir-lang/elixir|Elixir Language}
  """

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
      String.contains?(domain, "github.com") -> github_icon()
      String.contains?(domain, "gitlab.com") -> gitlab_icon()
      String.contains?(domain, "youtube.com") -> youtube_icon()
      String.contains?(domain, "twitter.com") or String.contains?(domain, "x.com") -> twitter_icon()
      true -> link_icon()
    end
  end

  defp github_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/></svg>)
  end

  defp gitlab_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M8 15.363l2.26-6.963H5.74L8 15.363zM1.174 8.4l-.97 2.986a.667.667 0 00.242.746l7.553 5.49L1.175 8.4zm13.652 0L8.002 17.62l7.553-5.49a.667.667 0 00.242-.745l-.97-2.986zM2.02 8.4h3.72L4.138 3.11a.333.333 0 00-.634 0L2.02 8.4zm11.96 0L12.496 3.11a.333.333 0 00-.634 0L10.26 8.4h3.72z"/></svg>)
  end

  defp youtube_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M8.051 1.999h.089c.822.003 4.987.033 6.11.335a2.01 2.01 0 0 1 1.415 1.42c.101.38.172.883.22 1.402l.01.104.022.26.008.104c.065.914.073 1.77.074 1.957v.075c-.001.194-.01 1.108-.082 2.06l-.008.105-.009.104c-.05.572-.124 1.14-.235 1.558a2.007 2.007 0 0 1-1.415 1.42c-1.16.312-5.569.334-6.18.335h-.142c-.309 0-1.587-.006-2.927-.052l-.17-.006-.087-.004-.171-.007-.171-.007c-1.11-.049-2.167-.128-2.654-.26a2.007 2.007 0 0 1-1.415-1.419c-.111-.417-.185-.986-.235-1.558L.09 9.82l-.008-.104A31.4 31.4 0 0 1 0 7.68v-.123c.002-.215.01-.958.064-1.778l.007-.103.003-.052.008-.104.022-.26.01-.104c.048-.519.119-1.023.22-1.402a2.007 2.007 0 0 1 1.415-1.42c.487-.13 1.544-.21 2.654-.26l.17-.007.172-.006.086-.003.171-.007A99.788 99.788 0 0 1 7.858 2h.193zM6.4 5.209v4.818l4.157-2.408L6.4 5.209z"/></svg>)
  end

  defp twitter_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M12.6.75h2.454l-5.36 6.142L16 15.25h-4.937l-3.867-5.07-4.425 5.07H.316l5.733-6.57L0 .75h5.063l3.495 4.633L12.601.75Zm-.86 13.028h1.36L4.323 2.145H2.865l8.875 11.633Z"/></svg>)
  end

  defp link_icon do
    ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M4.715 6.542 3.343 7.914a3 3 0 1 0 4.243 4.243l1.828-1.829A3 3 0 0 0 8.586 5.5L8 6.086a1.002 1.002 0 0 0-.154.199 2 2 0 0 1 .861 3.337L6.88 11.45a2 2 0 1 1-2.83-2.83l.793-.792a4.018 4.018 0 0 1-.128-1.287z"/><path d="M6.586 4.672A3 3 0 0 0 7.414 9.5l.775-.776a2 2 0 0 1-.896-3.346L9.12 3.55a2 2 0 1 1 2.83 2.83l-.793.792c.112.42.155.855.128 1.287l1.372-1.372a3 3 0 1 0-4.243-4.243L6.586 4.672z"/></svg>)
  end
end
