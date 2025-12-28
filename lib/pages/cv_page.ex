defmodule Dieman.CvPage do
  use Dieman.Component

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "CV",
    permalink: "/cv"

  def template(assigns) do
    ~H"""
    <div class="cv">
      <p class="empty">Coming soon.</p>
    </div>
    """
  end
end
