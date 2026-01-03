defmodule Dieman do
  @moduledoc "Core utilities for dieman.dev."

  alias Dieman.Assets

  @doc "Generate an absolute URL from a relative path."
  def absolute_url(path) do
    base_url = Application.get_env(:tableau, :config)[:url]

    base_url
    |> URI.parse()
    |> URI.merge(path)
    |> URI.to_string()
  end

  @doc "Calculate reading time in minutes from content string."
  def reading_time(content) when is_binary(content) do
    words = content |> String.split(~r/\s+/) |> length()
    max(1, ceil(words / Assets.words_per_minute()))
  end

  def reading_time(_), do: 1

  @doc "Render live reload script in dev mode only."
  def live_reload(assigns) do
    if Mix.env() == :dev do
      Phoenix.HTML.raw(Tableau.live_reload(assigns))
    else
      ""
    end
  end

  @doc "Render analytics script in prod mode only."
  def analytics do
    if Mix.env() == :prod do
      Phoenix.HTML.raw("""
      <script defer src="https://static.cloudflareinsights.com/beacon.min.js" data-cf-beacon='{"token": "0e0791e666b34293881978c9a293a731"}'></script>
      <script defer src="https://cloud.umami.is/script.js" data-website-id="dca32d18-c12d-42a9-ba84-1751e2615c81"></script>
      """)
    else
      ""
    end
  end
end
