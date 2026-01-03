defmodule Dieman.Markdown.Components.Figure do
  @moduledoc """
  Processes figure syntax `::figure{src|alt|caption}` into HTML figures.

  ## Examples

  Default (centered):

      ::figure{/images/photo.jpg|Alt text|This is the caption}

  With alignment:

      ::figure[left]{/images/photo.jpg|Alt text}
      ::figure[center]{/images/photo.jpg|Alt text}
      ::figure[full]{/images/photo.jpg|Alt text}

  Grid of images (use generic ::grid wrapper):

      ::grid
      ::figure{/images/one.jpg|First}
      ::figure{/images/two.jpg|Second}
      ::
  """

  @doc """
  Replaces `::figure[align]{src|alt|caption}` patterns with figure elements.
  """
  def process(html) when is_binary(html) do
    # With alignment option: ::figure[left|center|full]{...}
    result1 = Regex.replace(~r/::figure\[(\w+)\]\{([^}]+)\}/, html, &replace_with_align/3)
    # Without alignment option (default centered): ::figure{...}
    Regex.replace(~r/::figure\{([^}]+)\}/, result1, &replace_default/2)
  end

  def process(html), do: html

  defp replace_with_align(_full, align, content), do: build_figure(content, align)
  defp replace_default(_full, content), do: build_figure(content, "center")

  defp build_figure(content, align) do
    align_class =
      case align do
        "left" -> "figure-left"
        "full" -> "figure-full"
        _ -> "figure-center"
      end

    case String.split(content, "|", parts: 3) do
      [src, alt, caption] ->
        src = String.trim(src)

        """
        <figure class="image-figure #{align_class}">
          <div class="image-wrapper" onclick="openImageLightbox('#{src}')">
            <img src="#{src}" alt="#{String.trim(alt)}" loading="lazy">
          </div>
          <figcaption>#{String.trim(caption)}</figcaption>
        </figure>
        """

      [src, alt] ->
        src = String.trim(src)

        """
        <figure class="image-figure #{align_class}">
          <div class="image-wrapper" onclick="openImageLightbox('#{src}')">
            <img src="#{src}" alt="#{String.trim(alt)}" loading="lazy">
          </div>
        </figure>
        """

      [src] ->
        src = String.trim(src)

        """
        <figure class="image-figure #{align_class}">
          <div class="image-wrapper" onclick="openImageLightbox('#{src}')">
            <img src="#{src}" alt="" loading="lazy">
          </div>
        </figure>
        """
    end
  end
end
