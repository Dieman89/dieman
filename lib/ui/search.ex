defmodule Dieman.UI.Search do
  @moduledoc "Search modal component."

  import Temple
  import Dieman.UI.Components, only: [icon: 1]

  def search_modal do
    temple do
      div id: "search-overlay", class: "search-overlay" do
        div class: "search-modal" do
          div class: "search-input-wrapper" do
            span(class: "search-icon", do: icon(:search))

            input(
              type: "search",
              id: "search-input",
              class: "search-input",
              placeholder: "Search posts and projects...",
              autocomplete: "off",
              aria_label: "Search"
            )

            span(class: "search-esc", do: "esc")
          end

          div(id: "search-results", class: "search-results", role: "listbox")
        end
      end
    end
  end
end
