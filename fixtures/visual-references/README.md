# Canonical DEX//PULSE Visual Reference Fixtures

These files were supplied directly by the project owner in the DEX//PULSE planning conversation and are authoritative references for the DEX//PULSE Strand renderer. Their original bytes are immutable fixtures; SHA-256 is the identity authority. The `2026-04-10` timestamp embedded in each filename is source naming metadata, not a claim about when this repository imported them.

## Original fixtures

The MP4 files in `original/` are the highest authority. Preserve their bytes unchanged.

All four are approximately 6.04 seconds at 24 fps. They demonstrate complementary aspects of the desired Starsilk-derived ribbon language:

- `grok_video_2026-04-10-03-54-13.mp4` — broad horizontal/diagonal ribbon motion, curvature, width, surface segmentation, and controlled depth rotation.
- `grok_video_2026-04-10-03-59-49.mp4` — narrow/edge-on ribbon presentation, dramatic twist, face-to-edge transition, and high-contrast barcode breakup.
- `grok_video_2026-04-10-04-01-42.mp4` — long single-ribbon S curves, consistent material treatment, and smooth tensioned travel through depth.
- `grok_video_2026-04-10-04-05-20.mp4` — multiple ribbons weaving/crossing while remaining independently readable; strongest reference for over/under separation and combined glow field.

## Contact sheets

`contact-sheets/` contains derived frame sheets for quick visual inspection. They are not authoritative substitutes for temporal review.

## Rules

- Do not recompress or replace the originals without an explicit owner decision.
- If new visual references are added, add their source, hash, metadata, and what they prove to `manifest.json` and `docs/VISUAL_REFERENCE_MANIFEST.md`.
- Golden renderer outputs belong in a separate future fixture directory and must never overwrite the owner-supplied references.
