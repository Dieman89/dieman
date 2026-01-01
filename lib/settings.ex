defmodule Dieman.Settings do
  @moduledoc "Site settings and configuration values."

  # Date/Time
  @date_format "%b %d, %Y"
  @default_post_time "01:00:00 -04:00"

  # Reading time
  @words_per_minute 200

  # Assets
  @stylesheet "/css/site.css"
  @glitch_script "/js/glitch.js"

  # Fonts
  @font_preconnect ["https://fonts.googleapis.com", "https://fonts.gstatic.com"]
  @font_stylesheet "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap"

  # Icons - read from static/svg at compile time
  @svg_dir Path.expand("../static/svg", __DIR__)
  @icon_names ~w(github linkedin rss calendar)a

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
  def font_preconnect, do: @font_preconnect
  def font_stylesheet, do: @font_stylesheet
  def icon(name), do: @icons[name]
end
