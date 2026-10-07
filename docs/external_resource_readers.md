# External Resource Readers

Pkl supports [external resource readers](https://pkl-lang.org/main/current/language-reference/index.html#external-resource-readers)
that serve custom URI schemes (e.g. `reader+helm:`, `reader+sops:`) through
the `--external-resource-reader <scheme>=<path>` CLI flag.

`rules_pkl` integrates this so that Bazel-built reader binaries are
automatically wired into `pkl_eval` and `pkl_test` targets with no per-target
configuration.

---

## 1. How Pkl resolves readers

Pkl resolves a custom scheme in two ways (last one wins):

1. **`evaluatorSettings.externalResourceReaders`** in the `PklProject` file —
   declares the scheme and a default `executable` path (resolved from `PATH`
   at evaluation time).
2. **`--external-resource-reader <scheme>=<abs-path>`** CLI flag — overrides the
   PklProject declaration with the exact binary to use.

`rules_pkl` passes the flag automatically. The PklProject declaration is still
required for non-Bazel consumers (e.g. `pkl eval` run locally without Bazel)
and for published packages.

---

## 2. Option A — Host-installed reader (non-hermetic)

If you are okay with the reader binary being resolved from `PATH` at build time:

```python
# BUILD.bazel
pkl_eval(
    name = "my_config",
    srcs = ["config.pkl"],
    use_default_shell_env = True,   # makes PATH available to the action
)
```

**Caveats:**
- `use_default_shell_env = True` is only available on `pkl_eval`, not
  `pkl_test`. For tests, use the `env` attribute or `--test_env`.
- The build is non-hermetic: different machines may have different reader
  versions, breaking reproducibility.
- The action inherits the full host environment via `--action_env`.

---

## 3. Option B — Bazel-built reader

Declare the reader in `MODULE.bazel` using `pkl.project()`:

```python
# MODULE.bazel
pkl = use_extension("@rules_pkl//pkl/extensions:pkl.bzl", "pkl")

pkl.project(
    name = "my_cache",
    external_resource_readers = {
        "//:my_reader": "reader+myscheme",
    },
    pkl_project = "//:PklProject",
    pkl_project_deps = "//:PklProject.deps.json",
)
use_repo(pkl, "my_cache")
```

Then depend on the generated cache target:

```python
# BUILD.bazel
pkl_eval(
    name = "my_config",
    srcs = ["config.pkl"],
    deps = ["@my_cache//:packages"],
)
```

The `@my_cache//:packages` target carries both the PklProject metadata and the
reader mapping. No manual `pkl_project_rule` or `pkl_cache` targets are needed.

**Accepted target kinds for reader labels:**

| Kind | `files_to_run` | Notes |
|------|---------------|-------|
| `go_binary`, `sh_binary`, custom executable rule | native `FilesToRunProvider` | Passed as a tool to the action |
| `genrule` output, `http_file` (with `executable = True`), `exports_files` of a single file | `None` (plain-file path) | `http_file` requires `executable = True`; plain-file readers have no runfiles |

**Manual wiring** (without `pkl.project()`):

```python
# BUILD.bazel
pkl_project_rule(
    name = "project",
    pkl_project_file = "PklProject",
    pkl_project_deps = "PklProject.deps.json",
    external_resource_readers = {
        "//:my_reader": "reader+myscheme",
    },
)

pkl_cache(
    name = "packages",
    pkl_project = ":project",   # accepts pkl_project_rule targets
    pkl_project_deps = "PklProject.deps.json",
    items = [...],
)
```

---

## 4. Readers with tool dependencies

A reader can depend on other Bazel-built targets by being an executable target
with `data`, for example a `sh_binary` that locates a real reader through the
[bash runfiles library](https://github.com/bazelbuild/rules_shell) and `exec`s it.
Statically linked binaries (e.g. `go_binary(pure = "on")`) need none of this.

How the reader's runfiles reach the process depends on the rule:

- **`pkl_eval`:** the reader is passed to the action as a tool, so Bazel stages
  the reader's own `<exe>.runfiles` tree next to it in the sandbox.
- **`pkl_test`:** the reader's runfiles are merged into the test's runfiles.

Both cases are covered by the `external_resource_reader` integration test
(`reader+echowrapped`), which runs sandboxed.

```python
# BUILD.bazel
sh_binary(
    name = "echo_reader_wrapper",
    srcs = ["echo_reader_wrapper.sh"],
    data = [":echo_reader"],
    deps = ["@rules_shell//shell/runfiles"],
    visibility = ["//visibility:public"],
)
```

```bash
# echo_reader_wrapper.sh (runfiles.bash init block omitted)
reader="$(rlocation _main/echo_reader_/echo_reader)"
if [[ -z "$reader" || ! -x "$reader" ]]; then
  echo "cannot locate reader (got '${reader}')" >&2
  exit 1
fi
exec "$reader" "$@"
```

Notes for wrapper authors:

- Pkl talks to the reader over stdin/stdout, so the wrapper must never write to
  stdout (send diagnostics to stderr) and should `exec` the real reader rather
  than run it as a child.
- Fail fast with a non-zero exit when the real reader cannot be located. If the
  wrapper dies during startup, the evaluation can appear to hang.
- Paths inside runfiles depend on the rule that built the reader. `rules_go`
  places the binary at `<name>_/<name>`, not `<name>`. Inspect the
  `<exe>.runfiles_manifest` if `rlocation` returns nothing. The runfiles
  library itself is published under
  `bazel_tools/tools/bash/runfiles/runfiles.bash` in the staged tree.
- The `args` and `env` attributes of the wrapper target are not applied when
  Pkl launches it.
- With `pkl-go`, do not `defer client.Close()` around `client.Run()`.
  `Run()` already closes the client, and a second close panics.

For readers that need tools installed on the host (e.g. `helm`, `sops`), use
`use_default_shell_env = True` on `pkl_eval` (Option A).

---

## 5. Publishing packages

If you publish a Pkl package that uses an external reader, declare the scheme
in `PklProject` so that non-Bazel consumers can resolve it:

```pkl
// PklProject
amends "pkl:Project"

evaluatorSettings {
  externalResourceReaders {
    ["reader+myscheme"] {
      // Non-Bazel consumers resolve this from PATH.
      // Bazel overrides this with the --external-resource-reader flag.
      executable = "my_reader"
    }
  }
}
```

If the scheme is wired via `external_resource_readers` in Bazel but not
declared in `evaluatorSettings`, `rules_pkl` prints a warning at repository
fetch time.

---

## 6. Limitations

- **Readers are built for the exec platform.** Under cross-compilation (e.g.
  target platform = iOS, exec platform = Linux x86_64), the reader binary is
  built for the exec platform. This is usually correct, but it means readers
  cannot reference target-platform-specific toolchain outputs.

- **Multiple caches are not supported.** A `pkl_eval` or `pkl_test` that
  transitively depends on more than one `pkl_cache` will fail at analysis time.
  Merge all items into a single `pkl_cache`. Caches with different
  `external_resource_readers` cannot be merged automatically.

- **Plain-file readers have no runfiles.** A non-executable reader target must
  have exactly one file. Such readers cannot use the bash runfiles library.

- **`pkl_cache` and `--experimental_output_paths=strip`.** Path mapping
  currently fails for any `pkl_eval` that depends on a `pkl_cache` (with or
  without readers), because the cache root is passed as an unmapped path
  string. This is independent of external resource readers.
