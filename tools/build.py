import os
import pathlib
from pathlib import Path

from transformer.template import apply_template

rootdir = pathlib.Path().absolute().joinpath("docs")
for directory, subs, files in os.walk(rootdir):
    for file in files:
        if not file.endswith(".md"):
            continue
        curr: Path = rootdir.joinpath(directory).joinpath(file)
        with curr.open(mode="r+", encoding="UTF-8") as f:
            print(f"Processing: {curr}")
            text = f.read()
            start = hash(text)
            text = apply_template(text)
            if start == hash(text):
                continue
            print(f"Changed {curr}")
            f.seek(0)
            f.write(text)
            f.truncate()
