# Data: What, Where, How?

Slides for the SIG-HPC meeting (Oct 29, 2026, Butler 100) on moving,
storing, and using data on Muscadine.

## Building

```bash
make -C talks/2026-10-sighpc          # -> data-what-where-how.pptx
make -C talks/2026-10-sighpc preview  # -> preview/slide-NN.png (needs LibreOffice)
```

## Files

- `data-what-where-how.md` — the deck. `#` headers become section dividers,
  `##` headers become content slides; speaker notes live in `::: notes`
  blocks (visible in Presenter View).
- `template.pptx` — the club's official PowerPoint template
  (`0_template_16x9.pptx`). Tracked; source of all branding assets.
- `reference.pptx` — pandoc reference document, generated from
  `template.pptx` (gitignored; `make` rebuilds it).
- `theme.sh` — builds `reference.pptx` from `template.pptx`. The club
  template keeps its branding (crumpled-paper background, maroon
  `#5D1625` footer band, MSU + SIGHPC logos) on hand-built sample slides,
  which pandoc's pptx writer discards — so this script relocates that
  branding onto the slide master and layouts, sets Century Gothic and the
  maroon accent in the theme, and re-composes the title and section-header
  layouts to match the template's centered slides. Re-run it after the
  club template changes; it aborts loudly if any patch anchor moves.
- `fix-code-size.py` — pandoc post-processing: pandoc hard-codes Courier
  for all code, so this renames it to Consolas (ships with Office; a
  compact monospace that sits better beside Century Gothic), sizes fenced
  code blocks to 14pt — splitting the single-run block pandoc emits under
  `--syntax-highlighting=none` into one run per line with explicit breaks —
  and sizes inline code in prose to ~85% of the surrounding body level so
  monospace doesn't read visually larger than the Gothic text around it.

Note: the theme font is Century Gothic (the template's typeface). This
machine doesn't have it installed, so LibreOffice previews show a
substitute; PowerPoint on a club machine renders it properly.

All facts (quotas, snapshot policy, transfer rules) come from `docs/` in
this repo — chiefly `docs/clusters/muscadine.md`,
`docs/getting-started/data-transfer.md`, and `docs/getting-help.md`.
