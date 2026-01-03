defmodule Dieman.Assets do
  @moduledoc "Asset paths, icons, and formatting settings."

  # Date/Time
  @date_format "%b %d, %Y"
  @default_post_time "01:00:00 -04:00"

  # Reading time
  @words_per_minute 200

  # Assets
  @stylesheet "/css/site.css"
  @glitch_script "/js/glitch.js"
  @toc_script "/js/toc.js"
  @progress_script "/js/progress.js"
  @copy_code_script "/js/copy-code.js"
  @back_to_top_script "/js/back-to-top.js"
  @like_heart_script "/js/like-heart.js"
  @search_script "/js/search.js"

  # Fonts
  @font_preconnect ["https://fonts.googleapis.com", "https://fonts.gstatic.com"]
  @font_stylesheet "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap"

  # Icons
  @svg_dir Path.expand("../static/svg", __DIR__)
  @icon_names ~w(github linkedin rss calendar discord search)a

  for name <- @icon_names do
    @external_resource Path.join(@svg_dir, "#{name}.svg")
  end

  @icons Map.new(@icon_names, fn name ->
           {name, File.read!(Path.join(@svg_dir, "#{name}.svg"))}
         end)

  # Accessors
  def date_format, do: @date_format
  def default_post_time, do: @default_post_time
  def words_per_minute, do: @words_per_minute
  def stylesheet, do: @stylesheet
  def glitch_script, do: @glitch_script
  def toc_script, do: @toc_script
  def progress_script, do: @progress_script
  def copy_code_script, do: @copy_code_script
  def back_to_top_script, do: @back_to_top_script
  def like_heart_script, do: @like_heart_script
  def search_script, do: @search_script
  def font_preconnect, do: @font_preconnect
  def font_stylesheet, do: @font_stylesheet
  def icon(name), do: @icons[name]
end
