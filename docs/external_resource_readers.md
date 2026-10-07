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

A reader that calls other host tools (e.g. `helm`, `sops`) needs those tools
available when Pkl spawns the reader subprocess.

> **Finding (D3):** The reader binary's own runfiles tree is **not** propagated
> into the `pkl_eval` action sandbox. Only the executable file itself is placed
> in the sandbox as a tool. This means:
>
> - **`pkl_eval`:** The reader subprocess runs with no `RUNFILES_DIR` and no
>   `$0.runfiles`. A `sh_binary` wrapper that uses the bash runfiles library to
>   locate a data-dep binary will hang waiting for the runfiles manifest that
>   never arrives.
> - **`pkl_test`:** The test's merged runfiles tree is available via
>   `RUNFILES_DIR`, so a `sh_binary` wrapper works correctly.
>
> **Recommendation:** For `pkl_eval`, use statically-linked reader binaries
> (e.g. `go_binary(pure = "on")`) that bundle all dependencies. For readers
> that genuinely need host tools, use `use_default_shell_env = True` on
> `pkl_eval` (Option A).

For `pkl_test`, a `sh_binary` with `data = [":my_reader"]` works:

```python
sh_binary(
    name = "my_reader_wrapper",
    srcs = ["my_reader_wrapper.sh"],
    data = [":my_reader"],
)
```

The test runner merges the wrapper's runfiles into the test's runfiles tree,
so `RUNFILES_DIR` points to the right place.

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

- **Reader runfiles are not available in `pkl_eval` actions.** See section 4.
