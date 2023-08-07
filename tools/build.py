import os
import pathlib
from pathlib import Path

from tools.transformer.template import apply_template

rootdir = pathlib.Path().absolute().joinpath("docs")
for directory, subs, files in os.walk(rootdir):
    print(f"subdir: {directory} dirs: {subs} files: {files}")
    for file in files:
        if not file.endswith(".md"):
            continue
        curr: Path = rootdir.joinpath(directory).joinpath(file)
        with curr.open(mode="r+") as f:
            apply_template(f)
