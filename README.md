<p align="center">
  <a href="https://dieman.dev">
    <img src="static/images/site.png" alt="dieman.dev" />
  </a>
  <br><br>
  <code>:posts |> Enum.concat(:cv) |> deploy_to_web()</code>
</p>

---

```bash
mix deps.get && mix start       # dev server at localhost:4999
mix build                       # build to site/ (CV auto-protected)
mix dieman.gen.post "Title"     # new post
```

CV is protected by Cloudflare Turnstile CAPTCHA + content-hashed URL.
