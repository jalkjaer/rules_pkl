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
reader mapping. `pkl.project()` is the supported way to wire readers.

**Accepted target kinds for reader labels:**

| Kind | `files_to_run` | Notes |
|------|---------------|-------|
| `go_binary`, `sh_binary`, custom executable rule | native `FilesToRunProvider` | Passed as a tool to the action |
| `genrule` output, `http_file` (with `executable = True`), `exports_files` of a single file | `None` (plain-file path) | `http_file` requires `executable = True`; plain-file readers have no runfiles |

---

## 4. Readers with tool dependencies

A reader is an ordinary executable target, so `data` and other runfiles work as
usual. Bazel keeps the reader's runfiles tree: with `pkl_eval` it is staged next
to the reader (`<exe>.runfiles`), and with `pkl_test` it is merged into the
test's runfiles. Locate files with the runfiles library of the reader's
language, for example
[rules_go's runfiles library](https://github.com/bazelbuild/rules_go/tree/master/go/runfiles).
Both cases are covered by the `external_resource_reader` integration test
(`reader+echodata`).

```python
# BUILD.bazel
go_binary(
    name = "echo_data_reader",
    srcs = ["echo_data_reader.go"],
    data = [":reader_prefix.txt"],
    deps = [
        "@com_github_apple_pkl_go//pkl",
        "@rules_go//go/runfiles",
    ],
)
```

Notes for reader authors:

- Pkl talks to the reader over stdin/stdout, so a reader must never write to
  stdout other than through the protocol. Send diagnostics to stderr.
- The `args` and `env` attributes of the reader target are not applied when
  Pkl launches it.
- With `pkl-go`, do not `defer client.Close()` around `client.Run()`.
  `Run()` already closes the client, and a second close panics.
- If the reader is started through a wrapper script, make sure the script does
  not exit before the real reader has started. `pkl eval` can hang in that case
  instead of reporting an error. Prefer a reader that finds its own runfiles, and
  return errors from `Read()` so Pkl reports them as evaluation errors.

For readers that need tools installed on the host (i.e. `sops`), use
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
