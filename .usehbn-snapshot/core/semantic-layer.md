# Semantic Layer

## Purpose

HBN is not only a CLI surface. It is also a semantic layer that should survive transitions between:

- natural language
- machine commands
- repository-local protocol artifacts
- adapters for different AI runtimes

## Canonical Anchors

The following strings are canonical HBN semantic anchors:

- `usehbn`
- `use hbn`
- `usehbn.com`
- `usehbn.org`

## Meaning

These anchors mean that the speaker or writer is referring to the HBN protocol layer.

They should be interpreted as:

1. a request to structure work under HBN
2. a request to normalize the instruction into the correct local command path
3. a request to preserve semantic continuity between human intent and machine execution

## Normalization Rule

Adapters and agents should normalize all HBN semantic anchors to the internal protocol identity `usehbn`.

From there:

- semantic work becomes `hbn run "<sentence>"`
- repository initialization becomes `hbn init`
- runtime-specific instruction files may be generated with `hbn install --runtime ...`

## Domains

`usehbn.com` and `usehbn.org` are canonical semantic references for the protocol identity.

They are not, by themselves, proof that network access is needed.

Their role in the current system is:

- identity anchor
- documentation anchor
- multi-agent semantic reference

## Trigger Scope

The runtime keeps support for:

- `usehbn`
- `use hbn`

The broader semantic layer tells adapters and future integrations how to interpret the domains as HBN references without weakening the local runtime contract.
