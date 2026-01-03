defmodule Dieman.Markdown.Components.Youtube do
  @moduledoc """
  Processes YouTube embed syntax `::youtube{VIDEO_ID}` into responsive iframes.

  Uses a facade pattern - shows thumbnail first, loads iframe on click.

  ## Example

      ::youtube{dQw4w9WgXcQ}
      ::youtube[center]{dQw4w9WgXcQ}
      ::youtube[full]{dQw4w9WgXcQ}

  Becomes a responsive 16:9 YouTube embed with lazy loading.
  """

  @doc """
  Replaces `::youtube{VIDEO_ID}` patterns with facade video embeds.
  """
  def process(html) do
    # With alignment: ::youtube[center|full]{id}
    html =
      Regex.replace(~r/::youtube\[(\w+)\]\{([^}]+)\}/, html, fn _, align, video_id ->
        build_embed(String.trim(video_id), align)
      end)

    # Without alignment (default): ::youtube{id}
    Regex.replace(~r/::youtube\{([^}]+)\}/, html, fn _, video_id ->
      build_embed(String.trim(video_id), "default")
    end)
  end

  defp build_embed(id, align) do
    align_class =
      case align do
        "center" -> " video-center"
        "full" -> " video-full"
        _ -> ""
      end

    """
    <div class="video-embed video-facade#{align_class}" data-video-id="#{id}">
      <img src="https://img.youtube.com/vi/#{id}/maxresdefault.jpg" alt="Video thumbnail" loading="lazy">
      <button class="video-play-btn" aria-label="Play video">
        <svg viewBox="0 0 68 48" width="68" height="48">
          <path d="M66.52,7.74c-0.78-2.93-2.49-5.41-5.42-6.19C55.79,.13,34,0,34,0S12.21,.13,6.9,1.55 C3.97,2.33,2.27,4.81,1.48,7.74C0.06,13.05,0,24,0,24s0.06,10.95,1.48,16.26c0.78,2.93,2.49,5.41,5.42,6.19 C12.21,47.87,34,48,34,48s21.79-0.13,27.1-1.55c2.93-0.78,4.64-3.26,5.42-6.19C67.94,34.95,68,24,68,24S67.94,13.05,66.52,7.74z" fill="#f00"></path>
          <path d="M 45,24 27,14 27,34" fill="#fff"></path>
        </svg>
      </button>
    </div>
    """
  end
end
