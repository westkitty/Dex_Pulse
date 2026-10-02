# DEX//PULSE Clean-Room / Prior-Art Boundary

DEX//PULSE may learn from existing products, especially QDuo, but the project is intended to remain independently implementable under the owner's eventual MIT-or-Unlicense choice.

## QDuo boundary

QDuo is GPL-3.0. Until the owner explicitly chooses GPL-compatible derivation, do not copy substantial QDuo source, shaders, tests, assets, or distinctive implementation code into this repository.

Allowed:

- observe public product behavior;
- read public documentation to understand platform failure modes;
- identify macOS APIs/mechanisms and reimplement independently;
- write our own tests from DEX//PULSE requirements;
- compare runtime behavior as a black-box/reference oracle;
- cite QDuo as prior art.

Not allowed under the current plan:

- transplant source files/functions;
- mechanically translate GPL implementation into new names/language;
- copy visual assets;
- copy project-specific test fixtures verbatim when they embody implementation expression rather than a public API fact.

Record any future intentional third-party code dependency with exact license/version/source before merge.
