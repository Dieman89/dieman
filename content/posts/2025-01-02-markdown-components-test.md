---
title: "Custom Markdown Components"
date: 2025-01-02
tags:
  - tech
---

This post tests all the custom markdown components available in this blog.

## Keyboard Shortcuts

You can display keyboard shortcuts inline. Press [[Cmd+K]] to open search,
or use [[Ctrl+Shift+P]] for the command palette.

Common shortcuts:

- Copy: [[Cmd+C]]
- Paste: [[Cmd+V]]
- Save: [[Cmd+S]]
- Undo: [[Cmd+Z]]

## YouTube Embeds

Embed YouTube videos with a simple shortcode:

::youtube{dQw4w9WgXcQ}

## Images with Captions

Display images with proper figure/figcaption markup:

::figure{/images/avatar.png|Profile avatar|My profile picture used across the site}

You can also use it without a caption:

::figure{/images/avatar.png|Just an avatar}

More examples with different images:

::figure{/images/projects/zen-monokai-ristretto.png|VS Code Theme|Zen Monokai Ristretto - a dark theme for VS Code}

::figure{/images/projects/systems.png|Systems Architecture|A diagram showing the system architecture}

::figure{/images/site.png|Site Preview|Preview of the website}

## File Trees

Display directory structures with syntax highlighting:

::tree[React App]
my-project/
  src/
    components/
      Button.tsx
      Input.tsx
      Modal.tsx
    pages/
      index.tsx
      about.tsx
    styles/
      global.css
  config/
    settings.json
  package.json
  README.md
::

Another example with an Elixir project:

::tree[Elixir Project]
lib/
  my_app/
    router.ex
    endpoint.ex
  my_app.ex
mix.exs
config/
  config.exs
  dev.exs
  prod.exs
::

## Comparison Tables

Display tables with winner highlighting for comparisons:

::compare

| Framework | Build Time |
|-----------|------------|
| Vite      | 0.5s       |
| Webpack   | 3.2s       |
| Parcel    | 2.1s       |

::

The first data row is automatically highlighted as the "winner" with green styling.

## Callout Boxes

Display notes, warnings, and tips:

::note
This is a note with important information that readers should be aware of.
::

::warning
Be careful with this approach as it may have unintended side effects.
::

::tip
Pro tip: use this pattern for better performance in production.
::

## Collapsible Sections

Hide content that can be expanded on click:

::details[Show implementation details]
This content is hidden by default. You can put code examples, lengthy explanations, or optional information here.

It supports **markdown** formatting inside too.
::

## Terminal Output

Display command-line interactions:

::terminal
$ mix compile
{green:Compiling 5 files (.ex)}
{yellow:warning: variable "foo" is unused}
{red:** (CompileError) undefined function bar/0}
{#ff8800:Custom orange with hex}
{cyan:Info: Build completed}
::

## Quotes with Attribution

::quote[Rich Hickey]
Simple made easy.
::

::quote[Alan Kay]
The best way to predict the future is to invent it.
::

## Diff Blocks

Show code changes with additions and removals:

::diff
- def hello(name) do
-   IO.puts("Hello #{name}")
- end
+ def hello(name, greeting \\ "Hello") do
+   IO.puts("#{greeting}, #{name}!")
+   :ok
+ end
::

## Badges

Inline labels for versions and status: ::badge[v2.0.0]{green} ::badge[deprecated]{red} ::badge[beta]{yellow} ::badge[new]{blue}

You can also use plain badges: ::badge[MIT License] ::badge[TypeScript]

## Link Cards

Rich link previews for external resources:

::link{https://github.com/elixir-lang/elixir|Elixir Programming Language}

::link{https://hexdocs.pm/phoenix/overview.html|Phoenix Framework Docs}

## Combining Components

You can use these alongside regular markdown:

> **Pro tip:** Use [[Cmd+Shift+F]] to search across all files in your project.

The file tree component works great for showing project structure in tutorials!
