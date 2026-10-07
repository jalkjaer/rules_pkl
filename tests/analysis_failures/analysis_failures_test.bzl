# Copyright © 2026 Apple Inc. and the Pkl project authors. All rights reserved.
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

"""Analysis-time tests for pkl_project_rule and pkl_cache validation."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//pkl/private:pkl_cache.bzl", "pkl_cache")  # buildifier: disable=bzl-visibility
load("//pkl/private:pkl_project_rule.bzl", "pkl_project_rule")  # buildifier: disable=bzl-visibility
load("//pkl/private:providers.bzl", "PklFileInfo")  # buildifier: disable=bzl-visibility

def _expect_failure_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ctx.attr.expected_failure)
    return analysistest.end(env)

_expect_failure_test = analysistest.make(
    _expect_failure_test_impl,
    expect_failure = True,
    attrs = {"expected_failure": attr.string(mandatory = True)},
)

def _deps_fallback_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    caches = target[PklFileInfo].caches.to_list()
    asserts.equals(env, 1, len(caches))
    asserts.equals(
        env,
        "tests/analysis_failures/PklProject.deps.json",
        caches[0].pkl_project_deps.short_path,
    )
    return analysistest.end(env)

_deps_fallback_test = analysistest.make(_deps_fallback_test_impl)

def analysis_failures_test_suite(name):
    """Declares fixtures (tagged manual) and the analysis tests that check them.

    Args:
        name: Name of the test_suite grouping all tests.
    """

    # Fixture: a filegroup with two files used as a (non-executable) reader.
    native.filegroup(
        name = "two_files",
        srcs = ["PklProject", "PklProject.deps.json"],
        tags = ["manual"],
    )

    pkl_project_rule(
        name = "project",
        pkl_project_file = "PklProject",
        pkl_project_deps = "PklProject.deps.json",
        tags = ["manual"],
    )

    # Single-file reader check.
    pkl_project_rule(
        name = "project_multi_file_reader",
        pkl_project_file = "PklProject",
        pkl_project_deps = "PklProject.deps.json",
        external_resource_readers = {":two_files": "reader+x"},
        tags = ["manual"],
    )
    _expect_failure_test(
        name = "multi_file_reader_test",
        target_under_test = ":project_multi_file_reader",
        expected_failure = "must have exactly one file, got 2",
    )

    # Duplicate scheme check: two distinct reader labels, same scheme.
    pkl_project_rule(
        name = "project_duplicate_scheme",
        pkl_project_file = "PklProject",
        pkl_project_deps = "PklProject.deps.json",
        external_resource_readers = {
            "PklProject": "reader+dup",
            "other.deps.json": "reader+dup",
        },
        tags = ["manual"],
    )
    _expect_failure_test(
        name = "duplicate_scheme_test",
        target_under_test = ":project_duplicate_scheme",
        expected_failure = "is mapped to by both",
    )

    # Conflicting pkl_project_deps between pkl_cache and pkl_project_rule.
    pkl_cache(
        name = "cache_deps_conflict",
        pkl_project = ":project",
        pkl_project_deps = "other.deps.json",
        items = [],
        tags = ["manual"],
    )
    _expect_failure_test(
        name = "deps_conflict_test",
        target_under_test = ":cache_deps_conflict",
        expected_failure = "differs from the pkl_project_deps of",
    )

    # Positive: pkl_cache inherits pkl_project_deps from the pkl_project_rule.
    pkl_cache(
        name = "cache_deps_fallback",
        pkl_project = ":project",
        items = [],
        tags = ["manual"],
    )
    _deps_fallback_test(
        name = "deps_fallback_test",
        target_under_test = ":cache_deps_fallback",
    )

    native.test_suite(
        name = name,
        tests = [
            ":multi_file_reader_test",
            ":duplicate_scheme_test",
            ":deps_conflict_test",
            ":deps_fallback_test",
        ],
    )
