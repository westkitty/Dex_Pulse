# DexDictate Coexistence Contract

DexDictate has priority when DEX//PULSE could interfere with its dictation/insertion/undo path.

Reference project: `westkitty/DexDictate_MacOS`.

## Protected DexDictate behavior

Pulse must not invalidate:

- current focused Accessibility element;
- selected text/replacement range;
- clipboard preservation/restore behavior;
- recording/transcribing trigger semantics;
- browser Accessibility-tree behavior;
- verified target identity before insertion;
- Undo Last Dictation proof/restore assumptions.

## Hard Pulse rules

1. Opening Pulse never writes, clears, swaps, or temporarily replaces the clipboard.
2. The Veil should be non-activating and must not seize keyboard focus simply by appearing.
3. Automatic Lens resolution never synthesizes `Cmd-C` to obtain selected text.
4. Existing clipboard contents may be read only as the final fallback object.
5. Any future explicit clipboard-capture Reflex is a separate post-open capability and must prove clipboard restoration + DexDictate compatibility before release.
6. Pulse hotkey registration must detect/report conflicts rather than silently shadowing DexDictate.
7. If both systems require mutually incompatible transient ownership, Pulse yields/cancels.

## Mandatory coexistence scenarios

- both apps idle;
- DexDictate recording, Pulse invoked;
- DexDictate transcribing, Pulse invoked;
- DexDictate about to insert into TextEdit/native editor;
- DexDictate browser composer insertion path;
- selected-text replacement in progress;
- verified Undo armed, then unrelated Pulse invocation;
- Pulse result open, then DexDictate invoked;
- clipboard contains user data before/after Pulse invocation;
- trigger-key settings changed in either app.

## Evidence

For each scenario capture:

- frontmost application PID/bundle before/after;
- focused AX element identity before/after where safe;
- pasteboard change count + hash/type summary (never secret content in logs);
- selected-range metadata where safely observable;
- DexDictate state before/after;
- Pulse state before/after;
- pass/fail reason.

If a conflict cannot be proven safe, V1 behavior is to yield.
