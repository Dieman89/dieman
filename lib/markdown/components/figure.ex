defmodule Dieman.Markdown.Components.Figure do
  @moduledoc """
  Processes figure syntax `::figure{src|alt|caption}` into HTML figures.

  ## Examples

      ::figure{/images/photo.jpg|Alt text|This is the caption}
      ::figure{/images/photo.jpg|Alt text}
      ::figure{/images/photo.jpg}
  """

  @doc """
  Replaces `::figure{src|alt|caption}` patterns with figure elements.
  """
  def process(html) do
    Regex.replace(~r/::figure\{([^}]+)\}/, html, fn _, content ->
      case String.split(content, "|", parts: 3) do
        [src, alt, caption] ->
          src = String.trim(src)

          """
          <figure class="image-figure">
            <div class="image-wrapper" onclick="openImageLightbox('#{src}')">
              <img src="#{src}" alt="#{String.trim(alt)}" loading="lazy">
            </div>
            <figcaption>#{String.trim(caption)}</figcaption>
          </figure>
          """

        [src, alt] ->
          src = String.trim(src)

          """
          <figure class="image-figure">
            <div class="image-wrapper" onclick="openImageLightbox('#{src}')">
              <img src="#{src}" alt="#{String.trim(alt)}" loading="lazy">
            </div>
          </figure>
          """

        [src] ->
          src = String.trim(src)

          """
          <figure class="image-figure">
            <div class="image-wrapper" onclick="openImageLightbox('#{src}')">
              <img src="#{src}" alt="" loading="lazy">
            </div>
          </figure>
          """
      end
    end)
  end
end
