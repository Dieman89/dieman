<p align="center">
  <img src="assets/avatar.jpeg" width="150" alt="Alessandro Buonerba" />
</p>

# dieman.dev

Personal site built with [Tableau](https://github.com/elixir-tools/tableau) (Elixir static site generator).

## Development

```bash
mix deps.get
mix tableau.server
```

Site available at http://localhost:4999

## Writing Posts

```bash
mix dieman.gen.post "My Post Title"
```

Or manually create `_posts/2025-01-15-my-post.md`:

```markdown
---
title: My Post Title
date: 2025-01-15
---

Your content here with **markdown** support.
```

| Directory | Visibility |
|-----------|------------|
| `_posts/` | Published (dev + prod) |
| `_drafts/` | Draft (dev only) |

## Build & Deploy

```bash
MIX_ENV=prod mix tableau.build
```

Output goes to `_site/`. Deployment to GitHub Pages is automatic on push to `main`.

## Structure

```
_drafts/      # Draft posts (dev only)
_posts/       # Published posts
extra/css/    # Styles
lib/layouts/  # Page layouts
lib/pages/    # Page modules
```
