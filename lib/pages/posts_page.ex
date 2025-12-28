defmodule Dieman.PostsPage do
  use Dieman.Component

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Posts",
    permalink: "/posts"

  def template(assigns) do
    ~H"""
    <div class="floats">
      <span class="float float-1" data-label="FunctionK"><span>~&gt;</span></span>
      <span class="float float-2" data-label="flatMap"><span>&gt;&gt;=</span></span>
      <span class="float float-3" data-label="Effect"><span>IO</span></span>
      <span class="float float-4" data-label="Higher-kinded"><span>F[_]</span></span>
      <span class="float float-5" data-label="Lift"><span>pure</span></span>
      <span class="float float-6" data-label="Infrastructure"><span>resource</span></span>
      <span class="float float-7" data-label="Reusable"><span>module</span></span>
      <span class="float float-8" data-label="HCL Arrow"><span>=&gt;</span></span>
      <span class="float float-9" data-label="Preview"><span>plan</span></span>
      <span class="float float-10" data-label="Persistence"><span>state</span></span>
      <span class="float float-11" data-label="Input"><span>var</span></span>
      <span class="float float-12" data-label="Iteration"><span>for_each</span></span>
    </div>
    <div class="post-list">
      <%= for post <- @posts do %>
        <article class="post-item">
          <time><%= Calendar.strftime(post.date, "%b %d, %Y") %></time>
          <a href={post.permalink}><%= post.title %></a>
        </article>
      <% end %>
    </div>
    <%= if Enum.empty?(@posts) do %>
      <p class="empty">No posts yet.</p>
    <% end %>
    """
  end
end
