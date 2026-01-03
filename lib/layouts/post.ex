defmodule Dieman.PostLayout do
  @moduledoc "Layout for posts and pages with sidebar navigation."

  use Tableau.Layout, layout: Dieman.RootLayout
  import Temple
  import Dieman.UI.Shell
  import Dieman.UI.Post
  alias Dieman.Assets

  def template(assigns) do
    current_path = assigns[:page][:permalink] || "/"

    temple do
      div class: "single" do
        sidebar(current_path)

        article do
          header do
            if assigns[:page][:date] do
              div class: "post-header-meta" do
                div class: "post-header-left" do
                  span class: "date" do
                    Calendar.strftime(@page.date, Assets.date_format())
                  end

                  tags(@page[:tags] || [])
                end

                if assigns[:page][:body] do
                  reading_time(@page.body)
                end
              end
            end

            h1(do: @page.title)
          end

          Phoenix.HTML.raw(render(@inner_content))
        end

        post_shapes()
      end
    end
  end
end
