defmodule Dieman.Assets do
  @moduledoc "Asset paths, icons, and formatting settings."

  # Site
  @github_username "Dieman89"

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
  @code_tabs_script "/js/code-tabs.js"
  @youtube_facade_script "/js/youtube-facade.js"
  @image_compare_script "/js/image-compare.js"
  @post_stats_script "/js/post-stats.js"

  # Fonts
  @font_preconnect ["https://fonts.googleapis.com", "https://fonts.gstatic.com"]
  @font_stylesheet "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@100;200;300;400;700&display=swap"

  # Icons
  @svg_dir Path.expand("../static/svg", __DIR__)
  @icon_names ~w(github linkedin rss calendar discord search eye pencil download home file folder user info warning lightbulb arrows_horizontal link gitlab youtube twitter file_document folder_open)a

  for name <- @icon_names do
    @external_resource Path.join(@svg_dir, "#{name}.svg")
  end

  @icons Map.new(@icon_names, fn name ->
           {name, File.read!(Path.join(@svg_dir, "#{name}.svg"))}
         end)

  # Accessors
  def github_username, do: @github_username
  def github_url(repo), do: "https://github.com/#{@github_username}/#{repo}"
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
  def code_tabs_script, do: @code_tabs_script
  def youtube_facade_script, do: @youtube_facade_script
  def image_compare_script, do: @image_compare_script
  def post_stats_script, do: @post_stats_script
  def font_preconnect, do: @font_preconnect
  def font_stylesheet, do: @font_stylesheet
  def icon(name), do: @icons[name]
end
