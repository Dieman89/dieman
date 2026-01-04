defmodule Dieman.Markdown.Components.X do
  @moduledoc """
  X (Twitter) tweet embed - fetches and renders at build time.

  Usage: ::tweet{tweet_id}
  Example: ::tweet{1234567890}
  Or with full URL: ::tweet{https://x.com/user/status/1234567890}
  """

  require Logger

  @syndication_url "https://cdn.syndication.twimg.com/tweet-result"
  @placeholder_prefix "<!--TWEET_PLACEHOLDER:"
  @placeholder_suffix "-->"

  def pre_process(content) when is_binary(content) do
    Regex.replace(~r/::tweet\{([^}]+)\}/, content, fn _, input ->
      tweet_id = extract_tweet_id(input)
      "#{@placeholder_prefix}#{tweet_id}#{@placeholder_suffix}"
    end)
  end

  def pre_process(content), do: content

  # Post-markdown: replace placeholders with rendered tweets
  def post_process(html) when is_binary(html) do
    Regex.replace(
      ~r/#{Regex.escape(@placeholder_prefix)}(\d+)#{Regex.escape(@placeholder_suffix)}/,
      html,
      fn _, tweet_id ->
        render_tweet(tweet_id)
      end
    )
    |> String.replace(~r/<p>(#{Regex.escape(@placeholder_prefix)})/, "\\1")
    |> String.replace(~r/(#{Regex.escape(@placeholder_suffix)})<\/p>/, "\\1")
  end

  def post_process(html), do: html

  defp extract_tweet_id(input) do
    input = String.trim(input)

    if String.contains?(input, "/status/") do
      input |> String.split("/status/") |> List.last() |> String.split("?") |> List.first()
    else
      input
    end
  end

  defp render_tweet(tweet_id) do
    case fetch_tweet(tweet_id) do
      {:ok, data} ->
        build_card(data)

      {:error, reason} ->
        Logger.warning("Failed to fetch tweet #{tweet_id}: #{reason}")
        build_fallback(tweet_id)
    end
  end

  defp fetch_tweet(tweet_id) do
    url = "#{@syndication_url}?id=#{tweet_id}&token=0"

    case Req.get(url) do
      {:ok, %{status: 200, body: body}} when is_map(body) ->
        {:ok, body}

      {:ok, %{status: status}} ->
        {:error, "HTTP #{status}"}

      {:error, error} ->
        {:error, inspect(error)}
    end
  end

  defp build_card(data) do
    user = data["user"] || %{}
    tweet_url = "https://x.com/#{user["screen_name"]}/status/#{data["id_str"]}"

    ~s(<div class="tweet-embed">
      <div class="tweet-card">
        <div class="tweet-header">
          <a href="https://x.com/#{user["screen_name"]}" target="_blank" rel="noopener" class="tweet-author">
            <img src="#{user["profile_image_url_https"]}" alt="#{escape(user["name"])}" class="tweet-avatar">
            <div class="tweet-author-info">
              <span class="tweet-author-name">#{escape(user["name"])}</span>
              <span class="tweet-author-handle">@#{user["screen_name"]}</span>
            </div>
          </a>
          <a href="#{tweet_url}" target="_blank" rel="noopener" class="tweet-logo" title="View on X">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
            </svg>
          </a>
        </div>
        <div class="tweet-content">#{process_text(data)}</div>
        #{build_media(data)}
        <div class="tweet-footer">
          <a href="#{tweet_url}" target="_blank" rel="noopener" class="tweet-date">#{format_date(data["created_at"])}</a>
          <div class="tweet-stats">
            <span class="tweet-stat">
              <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
                <path d="M16.697 5.5c-1.222-.06-2.679.51-3.89 2.16l-.805 1.09-.806-1.09C9.984 6.01 8.526 5.44 7.304 5.5c-1.243.07-2.349.78-2.91 1.91-.552 1.12-.633 2.78.479 4.82 1.074 1.97 3.257 4.27 7.129 6.61 3.87-2.34 6.052-4.64 7.126-6.61 1.111-2.04 1.03-3.7.477-4.82-.561-1.13-1.666-1.84-2.908-1.91zm4.187 7.69c-1.351 2.48-4.001 5.12-8.379 7.67l-.503.3-.504-.3c-4.379-2.55-7.029-5.19-8.382-7.67-1.36-2.5-1.41-4.86-.514-6.67.887-1.79 2.647-2.91 4.601-3.01 1.651-.09 3.368.56 4.798 2.01 1.429-1.45 3.146-2.1 4.796-2.01 1.954.1 3.714 1.22 4.601 3.01.896 1.81.846 4.17-.514 6.67z"/>
              </svg>
              #{format_number(data["favorite_count"] || 0)}
            </span>
          </div>
        </div>
      </div>
    </div>)
  end

  defp build_fallback(tweet_id) do
    url = "https://x.com/i/status/#{tweet_id}"

    ~s(<div class="tweet-embed">
      <div class="tweet-error">
        <a href="#{url}" target="_blank" rel="noopener">View tweet on X</a>
      </div>
    </div>)
  end

  defp process_text(data) do
    text = data["text"] || ""
    entities = data["entities"] || %{}

    replacements =
      []
      |> add_hashtags(entities["hashtags"])
      |> add_mentions(entities["user_mentions"])
      |> add_urls(entities["urls"])
      |> Enum.sort_by(& &1.start, :desc)

    Enum.reduce(replacements, text, fn %{start: s, finish: f, html: html}, acc ->
      String.slice(acc, 0, s) <> html <> String.slice(acc, f..-1//1)
    end)
    |> remove_media_urls(data)
    |> escape()
    |> restore_links()
  end

  defp add_hashtags(acc, nil), do: acc

  defp add_hashtags(acc, hashtags) do
    Enum.reduce(hashtags, acc, fn h, list ->
      [
        %{
          start: Enum.at(h["indices"], 0),
          finish: Enum.at(h["indices"], 1),
          html: "{{LINK||https://x.com/hashtag/#{h["text"]}||##{h["text"]}}}"
        }
        | list
      ]
    end)
  end

  defp add_mentions(acc, nil), do: acc

  defp add_mentions(acc, mentions) do
    Enum.reduce(mentions, acc, fn m, list ->
      [
        %{
          start: Enum.at(m["indices"], 0),
          finish: Enum.at(m["indices"], 1),
          html: "{{LINK||https://x.com/#{m["screen_name"]}||@#{m["screen_name"]}}}"
        }
        | list
      ]
    end)
  end

  defp add_urls(acc, nil), do: acc

  defp add_urls(acc, urls) do
    Enum.reduce(urls, acc, fn u, list ->
      [
        %{
          start: Enum.at(u["indices"], 0),
          finish: Enum.at(u["indices"], 1),
          html: "{{LINK||#{u["expanded_url"]}||#{u["display_url"]}}}"
        }
        | list
      ]
    end)
  end

  defp remove_media_urls(text, data) do
    case data["mediaDetails"] do
      nil ->
        text

      media ->
        Enum.reduce(media, text, fn m, acc ->
          String.replace(acc, m["url"] || "", "")
        end)
    end
    |> String.trim()
  end

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  defp restore_links(text) do
    Regex.replace(~r/\{\{LINK\|\|([^|]+)\|\|([^}]+)\}\}/, text, fn _, url, label ->
      ~s(<a href="#{url}" target="_blank" rel="noopener">#{label}</a>)
    end)
  end

  defp build_media(data) do
    case data["mediaDetails"] do
      nil -> ""
      [] -> ""
      media -> do_build_media(media, data)
    end
  end

  defp do_build_media(media, data) do
    first = List.first(media)
    type = first["type"]

    cond do
      type in ["video", "animated_gif"] ->
        build_video(first, data)

      type == "photo" ->
        build_photos(media)

      true ->
        ""
    end
  end

  defp build_video(media, data) do
    poster = media["media_url_https"]
    user = data["user"] || %{}
    tweet_url = "https://x.com/#{user["screen_name"]}/status/#{data["id_str"]}"

    ~s(<a href="#{tweet_url}" target="_blank" rel="noopener" class="tweet-media tweet-video-link">
      <img src="#{poster}" alt="Video thumbnail" loading="lazy">
      <div class="tweet-play-button">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M8 5v14l11-7z"/>
        </svg>
      </div>
    </a>)
  end

  defp build_photos(media) do
    photos = Enum.filter(media, &(&1["type"] == "photo"))
    count = length(photos)
    grid_class = if count > 1, do: " tweet-media-grid tweet-media-#{count}", else: ""

    images =
      Enum.map_join(photos, "", fn p ->
        ~s(<img src="#{p["media_url_https"]}" alt="Tweet image" loading="lazy">)
      end)

    ~s(<div class="tweet-media#{grid_class}">#{images}</div>)
  end

  defp format_date(nil), do: ""

  defp format_date(date_str) do
    case Date.from_iso8601(String.slice(date_str, 0, 10)) do
      {:ok, date} ->
        Calendar.strftime(date, "%b %d, %Y")

      _ ->
        date_str
    end
  end

  defp format_number(n) when n >= 1_000_000, do: "#{Float.round(n / 1_000_000, 1)}M"
  defp format_number(n) when n >= 1_000, do: "#{Float.round(n / 1_000, 1)}K"
  defp format_number(n), do: to_string(n)
end
