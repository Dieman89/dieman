defmodule Dieman.Markdown.Components.Youtube do
  @moduledoc """
  Processes YouTube embed syntax `::youtube{VIDEO_ID}` into responsive iframes.

  ## Example

      ::youtube{dQw4w9WgXcQ}

  Becomes a responsive 16:9 YouTube embed.
  """

  @doc """
  Replaces `::youtube{VIDEO_ID}` patterns with responsive video embeds.
  """
  def process(html) do
    Regex.replace(~r/::youtube\{([^}]+)\}/, html, fn _, video_id ->
      """
      <div class="video-embed">
        <iframe
          src="https://www.youtube.com/embed/#{String.trim(video_id)}"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
        </iframe>
      </div>
      """
    end)
  end
end
