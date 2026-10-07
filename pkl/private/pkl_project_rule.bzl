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
Implementation of 'pkl_project_rule'.
"""

load("@rules_pkl//pkl/private:providers.bzl", "PklMetadataInfo")

def _make_files_to_run(target):
    """Return a files_to_run-compatible struct for the given target.

    For executable targets (go_binary, sh_binary, custom rules) this is the
    native files_to_run object. For plain file targets (exports_files, http_file,
    gs_file) files_to_run.executable is None; in that case we use the first file
    from DefaultInfo.files directly as the executable so that plain downloaded
    binaries can be used as readers without wrapping them in an executable rule.
    """
    ftr = target[DefaultInfo].files_to_run
    if ftr.executable != None:
        return ftr

    # Plain file target: synthesise a files_to_run-compatible struct.
    files = target[DefaultInfo].files.to_list()
    if not files:
        fail("external_resource_readers: target {} has no files".format(target.label))
    return struct(executable = files[0])

def _pkl_project_rule_impl(ctx):
    readers = []
    seen_schemes = {}
    for target, scheme in ctx.attr.external_resource_readers.items():
        if scheme in seen_schemes:
            fail("external_resource_readers: scheme '{}' is mapped to by both {} and {}".format(
                scheme,
                seen_schemes[scheme],
                target.label,
            ))
        seen_schemes[scheme] = target.label
        readers.append(struct(
            scheme = scheme,
            files_to_run = _make_files_to_run(target),
            default_runfiles = target[DefaultInfo].default_runfiles,
        ))
    return [
        DefaultInfo(files = depset([ctx.file.pkl_project_file])),
        PklMetadataInfo(
            pkl_project_file = ctx.file.pkl_project_file,
            pkl_project_deps = ctx.file.pkl_project_deps,
            external_resource_readers = readers,
        ),
    ]

pkl_project_rule = rule(
    _pkl_project_rule_impl,
    attrs = {
        "pkl_project_file": attr.label(
            allow_single_file = True,
            default = "PklProject",
        ),
        "pkl_project_deps": attr.label(
            allow_single_file = True,
            default = "PklProject.deps.json",
        ),
        "external_resource_readers": attr.label_keyed_string_dict(
            cfg = "exec",
            allow_files = True,
            doc = """Map from the label of the reader executable to its Pkl scheme name
(e.g. "reader+helm"). Accepts both executable targets (go_binary, sh_binary, custom
rules) and plain file targets (exports_files, http_file, gs_file). Each label is
built in the exec configuration and passed to the pkl CLI as
--external-resource-reader <scheme>=<path>. Two labels mapping to the same scheme
is an error.""",
        ),
    },
)
