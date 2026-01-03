defmodule Dieman.Markdown.Components.ImageCompare do
  @moduledoc """
  Processes before/after image comparison sliders.

  ## Example

      ::compare-images{/images/before.png|/images/after.png|Before|After}

  Creates a draggable slider to compare two images side by side.
  """

  alias Dieman.Assets

  @doc """
  Replaces `::compare-images{before|after|labelBefore|labelAfter}` with slider.
  """
  def process(html) do
    Regex.replace(
      ~r/::compare-images\{([^|]+)\|([^|]+)(?:\|([^|]+)\|([^}]+))?\}/,
      html,
      fn _, before_src, after_src, label_before, label_after ->
        label_before = if label_before && label_before != "", do: label_before, else: "Before"
        label_after = if label_after && label_after != "", do: label_after, else: "After"
        id = :erlang.unique_integer([:positive])

        """
        <div class="image-compare" data-compare-id="#{id}">
          <div class="image-compare-container">
            <div class="image-compare-after">
              <img src="#{String.trim(after_src)}" alt="#{label_after}" loading="lazy">
              <span class="image-compare-label image-compare-label-after">#{label_after}</span>
            </div>
            <div class="image-compare-before">
              <img src="#{String.trim(before_src)}" alt="#{label_before}" loading="lazy">
              <span class="image-compare-label image-compare-label-before">#{label_before}</span>
            </div>
            <div class="image-compare-slider">
              <div class="image-compare-handle">
                #{Assets.icon(:arrows_horizontal)}
              </div>
            </div>
          </div>
        </div>
        """
      end
    )
  end
end
