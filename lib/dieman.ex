defmodule Dieman do
  @moduledoc "Core utilities for dieman.dev."

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
    max(1, ceil(words / 200))
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
end
