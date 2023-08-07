import os
import pathlib
from typing import TextIO

rootdir = pathlib.Path().absolute().joinpath("templates")

templates = {}


def apply_template(text: str):
    return _process_templates(text, False)


def _process_templates(text: str, recursive: bool = True) -> str:
    start = hash(text)
    for k, v in templates.items():
        text = text.replace(f"{{{{ {k} }}}}", v)

    if start != hash(text) and recursive:
        return _process_templates(text)
    return text


def _load_templates():
    for file in os.listdir(rootdir):
        if not file.endswith(".md"):
            continue
        templates[file.replace(".md", "")] = open(rootdir.joinpath(file)).read().strip()


_load_templates()
templates = {k: _process_templates(v) for k, v in templates.items()}
