# DEX//PULSE Visual Fixture QA

## Authority

The exact original videos in `fixtures/visual-references/original/` are the highest visual authority for Strand material/motion. SHA-256 values in `fixtures/visual-references/SHA256SUMS.txt` must match before visual review.

## What each fixture proves

See `docs/VISUAL_REFERENCE_MANIFEST.md` for per-file metadata. Collectively they require:

- ribbon surface rather than glowing line;
- transverse barcode segmentation integrated into material;
- twist with face/edge/underside visibility and major apparent-width change;
- smooth tensioned curves;
- restrained bloom;
- readable over/under multi-ribbon crossings;
- distinct ribbons even in combined glow field.

## Deterministic renderer scenes

Create named scenes with fixed seed, geometry, camera/projection, viewport, scale factor, and timestamps:

- `strand_single_broad`
- `strand_edge_twist`
- `strand_s_curve`
- `strand_crossing_two`
- `strand_crossing_three`
- `strand_semantic_junction`
- `strand_dispatch_packet`
- `strand_fray`
- `strand_sever`
- `strand_recede`

## Review checklist

For every scene:

- ribbon never collapses into a generic luminous wire except during physically edge-on moments;
- barcode marks cross the surface rather than run along it;
- segmentation does not shimmer/moiré excessively in motion;
- underside remains darker enough to communicate twist;
- glow never erases surface edges;
- crossing order is readable frame-to-frame;
- crossings do not generate junction behavior;
- curvature feels tensioned/controlled, not springy, tentacular, or random;
- renderer pauses fully when scene is gone.

## Review outputs

Derived screenshots/contact sheets/golden videos may be committed under `fixtures/renderer-goldens/` only after approval. They are implementation evidence, not replacements for owner references.
