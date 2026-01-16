#    Copyright 2025 Genesis Corporation.
#
#    All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import os
import re
import sys
import json
import argparse
import urllib.request


REPO_URL = "https://repository.genesis-core.tech"
STABLE_RE = re.compile(r"^(?P<maj>\d+)\.(?P<min>\d+)\.(?P<patch>\d+)$")
DEV_RE = re.compile(
    r"^(?P<maj>\d+)\.(?P<min>\d+)\.(?P<patch>\d+)-dev\+(?P<ts>\d{14})\.(?P<hash>[0-9a-fA-F]{8})$"
)
RC_RE = re.compile(
    r"^(?P<maj>\d+)\.(?P<min>\d+)\.(?P<patch>\d+)-rc\+(?P<ts>\d{14})\.(?P<hash>[0-9a-fA-F]{8})$"
)


def parse_semver(s: str) -> tuple[int, int, int]:
    m = STABLE_RE.match(s)
    if not m:
        raise ValueError(f"Not a stable semver: {s}")
    return (int(m.group("maj")), int(m.group("min")), int(m.group("patch")))


def stable_sort_key(s: str) -> tuple[int, int, int]:
    return parse_semver(s)


def dev_sort_key(s: str) -> tuple[int, int, int, int, str]:
    m = DEV_RE.match(s)
    if not m:
        m = RC_RE.match(s)
        if not m:
            raise ValueError(f"Not a dev or rc semver: {s}")
    return (
        int(m.group("maj")),
        int(m.group("min")),
        int(m.group("patch")),
        int(m.group("ts")),
        m.group("hash"),
    )


def short_version(version: str) -> str:
    # For dev builds, short version is the part before the dash.
    # For stable builds, it's the version itself.
    return version.split("-", 1)[0]


def build_linux_url(base_name: str, version: str) -> str:
    # Base repository URL pattern as per example
    return f"{REPO_URL}/{base_name}/{version}/bundle_linux.tar.gz"


def build_win_url(base_name: str, version: str) -> str:
    # Base repository URL pattern as per example
    return f"{REPO_URL}/{base_name}/{version}/bundle_win.zip"


def collect_versions_dir(dir_path: str) -> list[str]:
    entries = []
    try:
        entries = os.listdir(dir_path)
    except FileNotFoundError:
        print(f"Directory not found: {dir_path}", file=sys.stderr)
        raise

    return entries


def collect_versions_http(url: str) -> list[str]:
    version_pattern = re.compile(r"href=\"(.+)\"")

    with urllib.request.urlopen(url) as response:
        html = response.read().decode("utf-8")

    versions = version_pattern.findall(html)

    result = []
    for version in versions:
        result.append(version.strip("/").replace("%2B", "+"))

    return result


def make_index(
    versions: list[str],
    min_stable: str,
    min_dev: str,
    base_name: str = "genesis_workspace",
) -> dict:
    stable_versions: list[str] = []
    dev_versions: list[str] = []
    for name in versions:
        if STABLE_RE.match(name):
            stable_versions.append(name)
        # The temporary solution is to consider RC and dev are the same
        elif DEV_RE.match(name) or RC_RE.match(name):
            dev_versions.append(name)
        else:
            # Ignore unrecognized entries
            continue

    # Sort versions descending
    stable_versions_sorted = sorted(
        stable_versions, key=stable_sort_key, reverse=True
    )
    dev_versions_sorted = sorted(dev_versions, key=dev_sort_key, reverse=True)

    latest_stable = (
        stable_versions_sorted[0] if stable_versions_sorted else None
    )
    latest_dev = dev_versions_sorted[0] if dev_versions_sorted else None

    # Build versions lists
    versions_stable = [
        {
            "version": v,
            "short_version": short_version(v),
            "linux": {"url": build_linux_url(base_name, v)},
            "win": {"url": build_win_url(base_name, v)},
        }
        for v in stable_versions_sorted
    ]

    versions_dev = [
        {
            "version": v,
            "short_version": short_version(v),
            "linux": {"url": build_linux_url(base_name, v)},
            "win": {"url": build_win_url(base_name, v)},
        }
        for v in dev_versions_sorted
    ]

    index: dict = {
        "spec": {"schema_version": "1"},
        "policy": {
            "update": {
                "min_version": {
                    "min_stable": min_stable,
                    "min_short_stable": (
                        short_version(min_stable) if min_stable else ""
                    ),
                    "min_dev": min_dev,
                    "min_short_dev": short_version(min_dev) if min_dev else "",
                }
            }
        },
        "latest": {
            "stable": {
                "version": latest_stable or "",
                "short_version": (
                    short_version(latest_stable) if latest_stable else ""
                ),
                "linux": {
                    "url": (
                        build_linux_url(base_name, latest_stable)
                        if latest_stable
                        else ""
                    )
                },
                "win": {
                    "url": (
                        build_win_url(base_name, latest_stable)
                        if latest_stable
                        else ""
                    )
                },
            },
            "dev": {
                "version": latest_dev or "",
                "short_version": (
                    short_version(latest_dev) if latest_dev else ""
                ),
                "linux": {
                    "url": (
                        build_linux_url(base_name, latest_dev)
                        if latest_dev
                        else ""
                    )
                },
                "win": {
                    "url": (
                        build_win_url(base_name, latest_dev)
                        if latest_dev
                        else ""
                    )
                },
            },
        },
        "versions": {"stable": versions_stable, "dev": versions_dev},
    }

    return index


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Generate workspace index JSON from a directory of version entries."
        )
    )
    parser.add_argument(
        "path",
        type=str,
        help=(
            "It'a directory or HTTP URL containing "
            "version entries (e.g., 1.2.3, 1.2.4-dev+<ts>.<hash>)"
        ),
    )
    parser.add_argument(
        "--min-stable",
        dest="min_stable",
        type=str,
        required=True,
        help="Minimum stable version to enforce (e.g., 1.4.1)",
    )
    parser.add_argument(
        "--min-dev",
        dest="min_dev",
        type=str,
        required=True,
        help="Minimum dev version to enforce (e.g., 1.4.2-dev+YYYYMMDDhhmmss.abcdef12)",
    )

    args = parser.parse_args()

    versions = (
        collect_versions_http(args.path)
        if args.path.startswith("http://") or args.path.startswith("https://")
        else collect_versions_dir(args.path)
    )

    index = make_index(versions, args.min_stable, args.min_dev)
    json.dump(index, sys.stdout, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
