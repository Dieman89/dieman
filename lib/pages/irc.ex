defmodule Dieman.Pages.Irc do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "IRC",
    permalink: "/irc"

  import Temple

  def template(_assigns) do
    temple do
      div class: "chat-container" do
        div class: "chat-header" do
          span class: "chat-header-channel" do
            "#dieman"
          end

          span class: "chat-header-meta" do
            "@ liberachat"
          end

          span class: "chat-header-sep" do
            "-"
          end

          span class: "chat-header-users", id: "chat-user-count" do
            "0 users"
          end

          div class: "chat-header-status", id: "chat-status" do
            span(class: "chat-status-dot")
          end
        end

        div class: "chat-topic-bar" do
          div class: "chat-topic-text", id: "chat-topic" do
            "Connecting..."
          end

          div(class: "chat-topic-meta", id: "chat-topic-meta")
        end

        div class: "chat-body" do
          div class: "chat-main" do
            div(class: "chat-messages", id: "chat-messages")

            div class: "chat-input-bar" do
              span class: "chat-input-nick", id: "chat-nick" do
                "guest"
              end

              form class: "chat-input-form", id: "chat-form" do
                input(
                  type: "text",
                  id: "chat-input",
                  class: "chat-input",
                  placeholder: "Send message...",
                  autocomplete: "off",
                  disabled: true
                )
              end
            end
          end

          div class: "chat-sidebar" do
            div(class: "chat-users", id: "chat-users")
          end
        end
      end

      script(src: "/js/irc.js")
    end
  end
end
