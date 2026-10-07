# Copyright © 2024-2025 Apple Inc. and the Pkl project authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
Declaring packages _expected_ to be in the cache (populated by pkl_deps repository rule).
"""

load(":pkl_package_names.bzl", "get_terminal_package_name")
load(":providers.bzl", "PklCacheInfo", "PklFileInfo", "PklMetadataInfo")

PklCacheEntryInfo = provider(
    fields = {
        "package_name": "The package name extracted from the package uri",
        "json": "The JSON file",
        "zip": "The zip file",
    },
    doc = "A provider containing information about a single entry in the Pkl cache.",
)

def _pkl_cached_package(ctx):
    return [
        PklCacheEntryInfo(
            package_name = ctx.attr.package_name,
            json = ctx.file.json,
            zip = ctx.file.zip,
        ),
    ]

pkl_cached_package = rule(
    _pkl_cached_package,
    attrs = {
        "package_name": attr.string(),
        "json": attr.label(allow_single_file = True),
        "zip": attr.label(allow_single_file = True),
    },
)

def _pkl_cache_impl(ctx):
    output_dir = ctx.actions.declare_directory(ctx.label.name)

    inputs = []
    args = ctx.actions.args()
    args.add(output_dir.path)
    cmd = """#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR="$1"
shift
mkdir -p "$OUTPUT_DIR"

"""

    for item in ctx.attr.items:
        info = item[PklCacheEntryInfo]
        args.add_all([info.json, info.zip])
        inputs.extend([info.json, info.zip])

        stem = "$OUTPUT_DIR/package-2/" + info.package_name

        file_name = get_terminal_package_name(info.package_name)

        cmd += """mkdir -p "{stem}"
cp "$1" "{stem}/{file_name}.json"
cp "$2" "{stem}/{file_name}.zip"
shift; shift;
""".format(
            stem = stem,
            file_name = file_name,
        )

    # Write the command to a temporary file so that we can debug later if necessary
    script = ctx.actions.declare_file("%s-script.sh" % ctx.label.name)
    ctx.actions.write(
        script,
        content = cmd,
        is_executable = True,
    )

    ctx.actions.run(
        executable = script,
        outputs = [output_dir],
        inputs = inputs,
        arguments = [args],
    )

    # Must be a tuple (immutable): PklCacheInfo is stored in a depset, and depset
    # elements may not contain mutable values such as lists.
    readers = ()
    pkl_project_meta = ctx.attr.pkl_project
    if pkl_project_meta and PklMetadataInfo in pkl_project_meta:
        readers = tuple(pkl_project_meta[PklMetadataInfo].external_resource_readers)

    return [
        DefaultInfo(
            files = depset([output_dir, script]),
            runfiles = ctx.runfiles([output_dir]),
        ),
        PklFileInfo(
            dep_files = depset(),
            caches = depset([
                PklCacheInfo(
                    root = output_dir,
                    pkl_project = ctx.file.pkl_project,
                    pkl_project_deps = ctx.file.pkl_project_deps,
                    label = ctx.label,
                    external_resource_readers = readers,
                ),
            ]),
        ),
    ]

pkl_cache = rule(
    _pkl_cache_impl,
    attrs = {
        "items": attr.label_list(
            providers = [[PklCacheEntryInfo]],
        ),
        "pkl_project": attr.label(
            allow_single_file = True,
            doc = """The PklProject file, or a pkl_project_rule target. When a pkl_project_rule
target is passed, its external_resource_readers are inherited by every pkl_eval that
depends on this cache.""",
        ),
        "pkl_project_deps": attr.label(
            allow_single_file = True,
        ),
    },
)
