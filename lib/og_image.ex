defmodule Dieman.OgImage do
  @moduledoc "Generate Open Graph images for posts using Vix/libvips."

  # Suppress warnings for Vix NIF modules that are loaded at runtime
  @compile {:no_warn_undefined, Vix.Vips.Image}
  @compile {:no_warn_undefined, Vix.Vips.Operation}

  alias Vix.Vips.Image
  alias Vix.Vips.Operation

  # OG image dimensions
  @width 1200
  @height 630

  # Monokai Pro Ristretto colors (RGB)
  @bg {0x2C, 0x25, 0x25}
  @fg {0xFF, 0xF8, 0xF9}
  @orange {0xF3, 0x8D, 0x70}
  @green {0xAD, 0xDA, 0x78}
  @red {0xFD, 0x68, 0x83}
  @yellow {0xFC, 0xE5, 0x66}
  @blue {0x85, 0xDA, 0xDC}
  @purple {0xA8, 0xA9, 0xEB}

  @title_font "JetBrains Mono Bold"
  @title_size 58
  @site_font "JetBrains Mono"
  @site_size 26
  @tag_font "JetBrains Mono Medium"
  @tag_size 18

  @heart_api "https://heart-counter.a-buonerba.workers.dev/api/hearts"
  @posts_dir "content/posts"
  @og_dir "static/og"

  @doc "Generate OG images for all posts."
  def generate_all do
    File.mkdir_p!(@og_dir)

    @posts_dir
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".md"))
    |> Enum.each(&generate_for_post/1)
  end

  defp generate_for_post(filename) do
    path = Path.join(@posts_dir, filename)

    with {:ok, content} <- File.read(path),
         {:ok, frontmatter} <- parse_frontmatter(content) do
      title = frontmatter["title"] || "Untitled"
      tags = frontmatter["tags"] || []
      slug = Slug.slugify(title, separator: "-")
      output = Path.join(@og_dir, "#{slug}.png")

      Mix.shell().info("OG: #{slug}")

      case generate(title, "/posts/#{slug}", output, tags: tags) do
        :ok -> :ok
        {:error, reason} -> Mix.shell().error("OG failed: #{inspect(reason)}")
      end
    else
      _ -> Mix.shell().error("Parse failed: #{filename}")
    end
  end

  defp parse_frontmatter(content) do
    case String.split(content, ~r/^---\s*$/m, parts: 3) do
      ["", yaml, _body] -> YamlElixir.read_from_string(yaml)
      _ -> {:error, :invalid_frontmatter}
    end
  end

  @doc "Generate OG image for a post and save to output path."
  def generate(title, permalink, output_path, opts \\ []) do
    tags = Keyword.get(opts, :tags, [])
    heart_count = fetch_heart_count(permalink)

    with {:ok, bg} <- create_background(),
         {:ok, img1} <- add_accent_line(bg),
         {:ok, img2} <- add_floating_shapes(img1),
         {:ok, img3} <- add_site_branding(img2),
         {:ok, img4} <- add_tags(img3, tags),
         {:ok, img5} <- add_title(img4, title),
         {:ok, img6} <- add_avatar(img5),
         {:ok, final} <- add_heart_count(img6, heart_count) do
      File.mkdir_p!(Path.dirname(output_path))
      Image.write_to_file(final, output_path)
    end
  end

  @doc "Fetch heart count from Cloudflare Worker API."
  def fetch_heart_count(permalink) do
    # Ensure trailing slash to match website's path format
    normalized = if String.ends_with?(permalink, "/"), do: permalink, else: permalink <> "/"
    url = "#{@heart_api}#{normalized}"

    case :httpc.request(:get, {String.to_charlist(url), []}, [{:timeout, 5000}], []) do
      {:ok, {{_, 200, _}, _, body}} ->
        case Jason.decode(to_string(body)) do
          {:ok, %{"count" => count}} -> count
          _ -> 0
        end

      _ ->
        0
    end
  end

  defp solid_color(width, height, {r, g, b}) do
    with {:ok, black} <- Operation.black(width, height),
         {:ok, red_ch} <- Operation.linear(black, [1.0], [r / 1]),
         {:ok, black2} <- Operation.black(width, height),
         {:ok, green_ch} <- Operation.linear(black2, [1.0], [g / 1]),
         {:ok, black3} <- Operation.black(width, height),
         {:ok, blue_ch} <- Operation.linear(black3, [1.0], [b / 1]),
         {:ok, black4} <- Operation.black(width, height),
         {:ok, alpha_ch} <- Operation.linear(black4, [1.0], [255.0]),
         {:ok, rgba} <- Operation.bandjoin([red_ch, green_ch, blue_ch, alpha_ch]) do
      Operation.copy(rgba, interpretation: :VIPS_INTERPRETATION_sRGB)
    end
  end

  defp create_background do
    solid_color(@width, @height, @bg)
  end

  @avatar_path "static/images/avatar.jpeg"
  @avatar_size 120
  @avatar_border 3
  @padding 60
  @bottom_y @height - 70

  defp add_avatar(img) do
    avatar_path = Path.expand(@avatar_path, File.cwd!())

    if File.exists?(avatar_path) do
      with {:ok, avatar} <- Image.new_from_file(avatar_path),
           {:ok, resized} <-
             Operation.thumbnail_image(avatar, @avatar_size,
               height: @avatar_size,
               crop: :VIPS_INTERESTING_CENTRE
             ),
           {:ok, circular} <- make_circular(resized),
           {:ok, with_border} <- add_avatar_border(circular) do
        # Position in bottom left
        Operation.composite2(img, with_border, :VIPS_BLEND_MODE_OVER,
          x: @padding - @avatar_border,
          y: @bottom_y - @avatar_size - @avatar_border + 10
        )
      end
    else
      {:ok, img}
    end
  end

  defp add_avatar_border(avatar) do
    size = Image.width(avatar)
    total_size = size + @avatar_border * 2
    half = total_size / 2

    with {:ok, x_coords} <- Operation.xyz(total_size, total_size),
         {:ok, x_band} <- Operation.extract_band(x_coords, 0),
         {:ok, y_band} <- Operation.extract_band(x_coords, 1),
         {:ok, x_centered} <- Operation.linear(x_band, [1.0], [-half]),
         {:ok, y_centered} <- Operation.linear(y_band, [1.0], [-half]),
         {:ok, x_sq} <- Operation.multiply(x_centered, x_centered),
         {:ok, y_sq} <- Operation.multiply(y_centered, y_centered),
         {:ok, dist_sq} <- Operation.add(x_sq, y_sq),
         {:ok, outer} <-
           Operation.relational_const(dist_sq, :VIPS_OPERATION_RELATIONAL_LESSEQ, [half * half]),
         {:ok, inner_radius} <- {:ok, half - @avatar_border},
         {:ok, inner} <-
           Operation.relational_const(dist_sq, :VIPS_OPERATION_RELATIONAL_LESSEQ, [
             inner_radius * inner_radius
           ]),
         {:ok, inner_inv} <- Operation.invert(inner),
         {:ok, ring} <- Operation.boolean(outer, inner_inv, :VIPS_OPERATION_BOOLEAN_AND),
         {:ok, ring_scaled} <- Operation.linear(ring, [255.0], [0.0]),
         {:ok, ring_cast} <- Operation.cast(ring_scaled, :VIPS_FORMAT_UCHAR),
         {:ok, border_base} <- solid_color_alpha(total_size, total_size, @orange, 255),
         {:ok, border_rgb} <- Operation.extract_band(border_base, 0, n: 3),
         {:ok, border_ring} <- Operation.bandjoin([border_rgb, ring_cast]),
         {:ok, border_final} <-
           Operation.copy(border_ring, interpretation: :VIPS_INTERPRETATION_sRGB) do
      Operation.composite2(border_final, avatar, :VIPS_BLEND_MODE_OVER,
        x: @avatar_border,
        y: @avatar_border
      )
    end
  end

  defp make_circular(image) do
    size = Image.width(image)
    half = size / 2

    with {:ok, x_coords} <- Operation.xyz(size, size),
         {:ok, x_band} <- Operation.extract_band(x_coords, 0),
         {:ok, y_band} <- Operation.extract_band(x_coords, 1),
         {:ok, x_centered} <- Operation.linear(x_band, [1.0], [-half]),
         {:ok, y_centered} <- Operation.linear(y_band, [1.0], [-half]),
         {:ok, x_sq} <- Operation.multiply(x_centered, x_centered),
         {:ok, y_sq} <- Operation.multiply(y_centered, y_centered),
         {:ok, dist_sq} <- Operation.add(x_sq, y_sq),
         {:ok, mask} <-
           Operation.relational_const(dist_sq, :VIPS_OPERATION_RELATIONAL_LESSEQ, [half * half]),
         {:ok, mask_255} <- Operation.linear(mask, [255.0], [0.0]),
         {:ok, mask_cast} <- Operation.cast(mask_255, :VIPS_FORMAT_UCHAR) do
      bands = Image.bands(image)

      if bands >= 3 do
        with {:ok, rgb} <- Operation.extract_band(image, 0, n: 3),
             {:ok, masked} <- Operation.bandjoin([rgb, mask_cast]) do
          Operation.copy(masked, interpretation: :VIPS_INTERPRETATION_sRGB)
        end
      else
        {:ok, image}
      end
    end
  end

  @shape_opacity 77

  defp add_floating_shapes(img) do
    shapes = [
      {:square_outline, 60, @red, @width - 300, 100},
      {:filled_circle, 40, @green, @width - 180, 380},
      {:triangle, 50, @yellow, @width - 480, 80},
      {:circle_outline, 80, @blue, @width - 420, 420},
      {:filled_square, 30, @purple, @width - 120, 80}
    ]

    Enum.reduce_while(shapes, {:ok, img}, fn shape, {:ok, acc} ->
      case draw_shape(acc, shape) do
        {:ok, new_img} -> {:cont, {:ok, new_img}}
        error -> {:halt, error}
      end
    end)
  end

  defp draw_shape(img, {:square_outline, size, color, x, y}) do
    with {:ok, shape} <- create_square_outline(size, color) do
      Operation.composite2(img, shape, :VIPS_BLEND_MODE_OVER, x: x, y: y)
    end
  end

  defp draw_shape(img, {:filled_circle, size, color, x, y}) do
    with {:ok, shape} <- create_filled_circle(size, color) do
      Operation.composite2(img, shape, :VIPS_BLEND_MODE_OVER, x: x, y: y)
    end
  end

  defp draw_shape(img, {:triangle, size, color, x, y}) do
    with {:ok, shape} <- create_triangle(size, color) do
      Operation.composite2(img, shape, :VIPS_BLEND_MODE_OVER, x: x, y: y)
    end
  end

  defp draw_shape(img, {:circle_outline, size, color, x, y}) do
    with {:ok, shape} <- create_circle_outline(size, color) do
      Operation.composite2(img, shape, :VIPS_BLEND_MODE_OVER, x: x, y: y)
    end
  end

  defp draw_shape(img, {:filled_square, size, color, x, y}) do
    with {:ok, shape} <- create_filled_square(size, color) do
      Operation.composite2(img, shape, :VIPS_BLEND_MODE_OVER, x: x, y: y)
    end
  end

  defp create_square_outline(size, {r, g, b}) do
    border = 2

    with {:ok, outer} <- solid_color_alpha(size, size, {r, g, b}, @shape_opacity),
         {:ok, inner} <- solid_color_alpha(size - border * 2, size - border * 2, @bg, 255) do
      Operation.composite2(outer, inner, :VIPS_BLEND_MODE_OVER, x: border, y: border)
    end
  end

  defp create_filled_circle(size, {r, g, b}) do
    half = size / 2

    with {:ok, x_coords} <- Operation.xyz(size, size),
         {:ok, x_band} <- Operation.extract_band(x_coords, 0),
         {:ok, y_band} <- Operation.extract_band(x_coords, 1),
         {:ok, x_centered} <- Operation.linear(x_band, [1.0], [-half]),
         {:ok, y_centered} <- Operation.linear(y_band, [1.0], [-half]),
         {:ok, x_sq} <- Operation.multiply(x_centered, x_centered),
         {:ok, y_sq} <- Operation.multiply(y_centered, y_centered),
         {:ok, dist_sq} <- Operation.add(x_sq, y_sq),
         {:ok, mask} <-
           Operation.relational_const(dist_sq, :VIPS_OPERATION_RELATIONAL_LESSEQ, [half * half]),
         {:ok, mask_scaled} <- Operation.linear(mask, [@shape_opacity / 1.0], [0.0]),
         {:ok, mask_cast} <- Operation.cast(mask_scaled, :VIPS_FORMAT_UCHAR),
         {:ok, base} <- solid_color_alpha(size, size, {r, g, b}, 255),
         {:ok, rgb} <- Operation.extract_band(base, 0, n: 3),
         {:ok, result} <- Operation.bandjoin([rgb, mask_cast]) do
      Operation.copy(result, interpretation: :VIPS_INTERPRETATION_sRGB)
    end
  end

  defp create_triangle(size, {r, g, b}) do
    height = round(size * 0.866)
    half_size = size / 2.0

    with {:ok, x_coords} <- Operation.xyz(size, height),
         {:ok, x_band} <- Operation.extract_band(x_coords, 0),
         {:ok, y_band} <- Operation.extract_band(x_coords, 1),
         {:ok, left_bound} <- Operation.linear(y_band, [-half_size / height], [half_size]),
         {:ok, left_ok} <-
           Operation.relational(x_band, left_bound, :VIPS_OPERATION_RELATIONAL_MOREEQ),
         {:ok, right_bound} <- Operation.linear(y_band, [half_size / height], [half_size]),
         {:ok, right_ok} <-
           Operation.relational(x_band, right_bound, :VIPS_OPERATION_RELATIONAL_LESSEQ),
         {:ok, inside} <- Operation.boolean(left_ok, right_ok, :VIPS_OPERATION_BOOLEAN_AND),
         {:ok, mask_scaled} <- Operation.linear(inside, [@shape_opacity / 1.0], [0.0]),
         {:ok, mask_cast} <- Operation.cast(mask_scaled, :VIPS_FORMAT_UCHAR),
         {:ok, base} <- solid_color_alpha(size, height, {r, g, b}, 255),
         {:ok, rgb} <- Operation.extract_band(base, 0, n: 3),
         {:ok, result} <- Operation.bandjoin([rgb, mask_cast]) do
      Operation.copy(result, interpretation: :VIPS_INTERPRETATION_sRGB)
    end
  end

  defp create_circle_outline(size, {r, g, b}) do
    half = size / 2
    border = 2.0
    inner_radius = half - border

    with {:ok, x_coords} <- Operation.xyz(size, size),
         {:ok, x_band} <- Operation.extract_band(x_coords, 0),
         {:ok, y_band} <- Operation.extract_band(x_coords, 1),
         {:ok, x_centered} <- Operation.linear(x_band, [1.0], [-half]),
         {:ok, y_centered} <- Operation.linear(y_band, [1.0], [-half]),
         {:ok, x_sq} <- Operation.multiply(x_centered, x_centered),
         {:ok, y_sq} <- Operation.multiply(y_centered, y_centered),
         {:ok, dist_sq} <- Operation.add(x_sq, y_sq),
         {:ok, outer} <-
           Operation.relational_const(dist_sq, :VIPS_OPERATION_RELATIONAL_LESSEQ, [half * half]),
         {:ok, inner} <-
           Operation.relational_const(dist_sq, :VIPS_OPERATION_RELATIONAL_LESSEQ, [
             inner_radius * inner_radius
           ]),
         {:ok, inner_inv} <- Operation.invert(inner),
         {:ok, ring} <- Operation.boolean(outer, inner_inv, :VIPS_OPERATION_BOOLEAN_AND),
         {:ok, mask_scaled} <- Operation.linear(ring, [@shape_opacity / 1.0], [0.0]),
         {:ok, mask_cast} <- Operation.cast(mask_scaled, :VIPS_FORMAT_UCHAR),
         {:ok, base} <- solid_color_alpha(size, size, {r, g, b}, 255),
         {:ok, rgb} <- Operation.extract_band(base, 0, n: 3),
         {:ok, result} <- Operation.bandjoin([rgb, mask_cast]) do
      Operation.copy(result, interpretation: :VIPS_INTERPRETATION_sRGB)
    end
  end

  defp create_filled_square(size, {r, g, b}) do
    solid_color_alpha(size, size, {r, g, b}, @shape_opacity)
  end

  defp solid_color_alpha(width, height, {r, g, b}, alpha) do
    with {:ok, black} <- Operation.black(width, height),
         {:ok, red_ch} <- Operation.linear(black, [1.0], [r / 1.0]),
         {:ok, black2} <- Operation.black(width, height),
         {:ok, green_ch} <- Operation.linear(black2, [1.0], [g / 1.0]),
         {:ok, black3} <- Operation.black(width, height),
         {:ok, blue_ch} <- Operation.linear(black3, [1.0], [b / 1.0]),
         {:ok, black4} <- Operation.black(width, height),
         {:ok, alpha_ch} <- Operation.linear(black4, [1.0], [alpha / 1.0]),
         {:ok, rgba} <- Operation.bandjoin([red_ch, green_ch, blue_ch, alpha_ch]) do
      Operation.copy(rgba, interpretation: :VIPS_INTERPRETATION_sRGB)
    end
  end

  defp add_title(img, title) do
    wrapped = wrap_text(title, 32)
    line_height = @title_size + 10
    start_y = 235

    wrapped
    |> Enum.with_index()
    |> Enum.reduce_while({:ok, img}, fn {line, idx}, {:ok, acc} ->
      y = start_y + idx * line_height

      case add_text(acc, line, @padding, y, @title_font, @title_size, @fg) do
        {:ok, new_img} -> {:cont, {:ok, new_img}}
        error -> {:halt, error}
      end
    end)
  end

  defp add_site_branding(img) do
    add_text(img, "dieman.dev", @padding, 30, @site_font, @site_size, @orange)
  end

  defp add_tags(img, []), do: {:ok, img}

  defp add_tags(img, tags) do
    tag_text =
      tags
      |> Enum.take(3)
      |> Enum.map_join("  ", &("#" <> String.upcase(&1)))

    add_text(img, tag_text, @padding, 200, @tag_font, @tag_size, @green)
  end

  defp add_heart_count(img, 0), do: {:ok, img}

  defp add_heart_count(img, count) do
    heart_text = "♥ #{count}"
    add_text(img, heart_text, @width - 140, @bottom_y - 20, @title_font, 36, @red)
  end

  defp add_accent_line(img) do
    with {:ok, line} <- solid_color(@width, 6, @orange) do
      Operation.composite2(img, line, :VIPS_BLEND_MODE_OVER, x: 0, y: 0)
    end
  end

  defp add_text(img, text, x, y, font, size, color) do
    font_string = "#{font} #{size}"

    with {:ok, {text_img, _meta}} <- Operation.text(text, font: font_string, rgba: true),
         {:ok, colored} <- colorize_rgba_text(text_img, color) do
      Operation.composite2(img, colored, :VIPS_BLEND_MODE_OVER, x: x, y: y)
    end
  end

  defp colorize_rgba_text(text_img, {r, g, b}) do
    width = Image.width(text_img)
    height = Image.height(text_img)

    with {:ok, alpha} <- Operation.extract_band(text_img, 3),
         {:ok, black1} <- Operation.black(width, height),
         {:ok, red_ch} <- Operation.linear(black1, [1.0], [r / 1]),
         {:ok, black2} <- Operation.black(width, height),
         {:ok, green_ch} <- Operation.linear(black2, [1.0], [g / 1]),
         {:ok, black3} <- Operation.black(width, height),
         {:ok, blue_ch} <- Operation.linear(black3, [1.0], [b / 1]),
         {:ok, colored} <- Operation.bandjoin([red_ch, green_ch, blue_ch, alpha]) do
      Operation.copy(colored, interpretation: :VIPS_INTERPRETATION_sRGB)
    end
  end

  defp wrap_text(text, max_chars) do
    words = String.split(text, " ")

    {lines, last} =
      Enum.reduce(words, {[], ""}, fn word, {lines, current} ->
        candidate = if current == "", do: word, else: "#{current} #{word}"

        if String.length(candidate) <= max_chars do
          {lines, candidate}
        else
          {lines ++ [current], word}
        end
      end)

    if last == "", do: lines, else: lines ++ [last]
  end

  @doc "Generate slug from post permalink."
  def slug_from_permalink(permalink) do
    permalink
    |> String.trim_leading("/posts/")
    |> String.replace(~r/[^a-z0-9-]/, "-")
  end
end
