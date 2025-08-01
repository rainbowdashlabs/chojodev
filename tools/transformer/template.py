import os
import pathlib
import tomllib

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
    with rootdir.parent.joinpath("code").joinpath("gradle_multimodule").joinpath("gradle").joinpath("libs.versions.toml").open("rb") as f:
        data = tomllib.load(f)
        print(data)
        versions = data["versions"]
        key: str
        for key, value in data["libraries"].items():
            group = value["group"]
            name = value["name"]
            version = value["version"]
            if "ref" in version:
                version = versions[version["ref"]]
            templates[f"VC_LIBRARY_{key.upper()}_GROUP"] = group
            templates[f"VC_LIBRARY_{key.upper()}_NAME"] = name
            templates[f"VC_LIBRARY_{key.upper()}_VERSION"] = version
            templates[f"VC_LIBRARY_{key.upper()}_MODULE"] = f"{group}:{name}"
            templates[f"VC_LIBRARY_{key.upper()}_FULL"] = f"{group}:{name}:{version}"

        for key, value in data["plugins"].items():
            templates[f"VC_PLUGIN_{key.upper()}_ID"] = value["id"]
            version = value["version"]
            if "ref" in version:
                version = version[value["ref"]]
            templates[f"VC_PLUGIN_{key.upper()}_VERSION"] = version


_load_templates()
templates = {k: _process_templates(v) for k, v in templates.items()}
