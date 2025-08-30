#!/usr/bin/env python3
"""Generate card art assets using prompts and an image API.

This script reads card prompts from ``docs/art_prompts.md`` and attempts to
create an image for each card using the OpenAI Images API.  Generated images
are stored inside ``Epochs/Assets.xcassets/{CardName}.imageset`` with a minimal
``Contents.json`` for Xcode.  Any failures are appended to
``tools/generate_art_failures.log`` for manual review.

The OpenAI API key is read from the ``OPENAI_API_KEY`` environment variable.
"""

from __future__ import annotations

import json
import logging
import os
import re
from pathlib import Path
from typing import Iterable, Tuple

try:
    import openai  # type: ignore
except Exception:  # pragma: no cover - import errors handled at runtime
    openai = None  # type: ignore

import requests

PROMPTS_FILE = Path("docs/art_prompts.md")
ASSETS_ROOT = Path("Epochs/Assets.xcassets")
FAIL_LOG = Path("tools/generate_art_failures.log")

LINE_RE = re.compile(r"- \*\*(?P<name>[^*]+)\*\* — (?P<prompt>.+)")


def read_prompts() -> Iterable[Tuple[str, str]]:
    """Yield (card name, prompt) tuples from the prompts file."""
    with PROMPTS_FILE.open("r", encoding="utf-8") as handle:
        for line in handle:
            match = LINE_RE.match(line.strip())
            if match:
                name = match.group("name").strip()
                prompt = match.group("prompt").strip()
                yield name, prompt


def save_image(name: str, image_bytes: bytes) -> None:
    """Save ``image_bytes`` to the imageset for ``name`` and create Contents.json."""
    imageset = ASSETS_ROOT / f"{name}.imageset"
    imageset.mkdir(parents=True, exist_ok=True)
    image_path = imageset / "image.png"
    with image_path.open("wb") as handle:
        handle.write(image_bytes)

    contents = {
        "images": [{"idiom": "universal", "filename": image_path.name}],
        "info": {"version": 1, "author": "xcode"},
    }
    with (imageset / "Contents.json").open("w", encoding="utf-8") as handle:
        json.dump(contents, handle, indent=2)


def generate_image(prompt: str) -> bytes:
    """Generate an image for ``prompt`` using the OpenAI Images API."""
    if openai is None:
        raise RuntimeError("openai package not available")

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY environment variable not set")

    openai.api_key = api_key
    response = openai.Image.create(prompt=prompt, n=1, size="1024x1024")
    url = response["data"][0]["url"]
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    return resp.content


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    for name, prompt in read_prompts():
        safe_name = name.replace("/", "-")
        full_prompt = f"{name}: {prompt}"
        try:
            image_bytes = generate_image(full_prompt)
            save_image(safe_name, image_bytes)
            logging.info("Generated art for %s", name)
        except Exception as exc:  # pragma: no cover - network failures
            logging.error("Failed to generate art for %s: %s", name, exc)
            with FAIL_LOG.open("a", encoding="utf-8") as log:
                log.write(f"{name}: {exc}\n")


if __name__ == "__main__":  # pragma: no cover
    main()
