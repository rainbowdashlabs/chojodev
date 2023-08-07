import os
import pathlib
from typing import TextIO

rootdir = pathlib.Path().absolute().joinpath("templates")

templates = {}


def apply_template(file: TextIO):
    text = file.read()
    start = hash(text)
    text = _process_templates(text, False)
    if start == hash(text):
        return
    file.seek(0)
    file.write(text)
    file.truncate()


def _process_templates(text: str, recursive: bool = True) -> str:
    start = text.__hash__()
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
