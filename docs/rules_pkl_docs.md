<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="pkl_cache"></a>

## pkl_cache

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_cache")

pkl_cache(<a href="#pkl_cache-name">name</a>, <a href="#pkl_cache-items">items</a>, <a href="#pkl_cache-pkl_project">pkl_project</a>, <a href="#pkl_cache-pkl_project_deps">pkl_project_deps</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_cache-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_cache-items"></a>items |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_cache-pkl_project"></a>pkl_project |  The PklProject file, or a pkl_project_rule target. When a pkl_project_rule target is passed, its external_resource_readers are inherited by every pkl_eval that depends on this cache.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="pkl_cache-pkl_project_deps"></a>pkl_project_deps |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="pkl_codegen_java_toolchain"></a>

## pkl_codegen_java_toolchain

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_codegen_java_toolchain")

pkl_codegen_java_toolchain(<a href="#pkl_codegen_java_toolchain-name">name</a>, <a href="#pkl_codegen_java_toolchain-cli">cli</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_codegen_java_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_codegen_java_toolchain-cli"></a>cli |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_pkl//pkl:pkl_codegen_java_cli"`  |


<a id="pkl_doc_toolchain"></a>

## pkl_doc_toolchain

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_doc_toolchain")

pkl_doc_toolchain(<a href="#pkl_doc_toolchain-name">name</a>, <a href="#pkl_doc_toolchain-cli">cli</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_doc_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_doc_toolchain-cli"></a>cli |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="pkl_eval"></a>

## pkl_eval

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_eval")

pkl_eval(<a href="#pkl_eval-name">name</a>, <a href="#pkl_eval-deps">deps</a>, <a href="#pkl_eval-srcs">srcs</a>, <a href="#pkl_eval-data">data</a>, <a href="#pkl_eval-outs">outs</a>, <a href="#pkl_eval-entrypoints">entrypoints</a>, <a href="#pkl_eval-expression">expression</a>, <a href="#pkl_eval-format">format</a>, <a href="#pkl_eval-multiple_outputs">multiple_outputs</a>, <a href="#pkl_eval-no_cache">no_cache</a>,
         <a href="#pkl_eval-properties">properties</a>, <a href="#pkl_eval-use_default_shell_env">use_default_shell_env</a>)
</pre>

Evaluate Pkl module(s).

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_eval-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_eval-deps"></a>deps |  Other targets to include in the pkl module path when building this configuration. Must be `pkl_*` targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_eval-srcs"></a>srcs |  The Pkl source files to be evaluated.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_eval-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_eval-outs"></a>outs |  Names of the output files to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. Expects a single file if `multiple_outputs` is not set to `True`.   | List of labels; <a href="https://bazel.build/reference/be/common-definitions#configurable-attributes">nonconfigurable</a> | optional |  `[]`  |
| <a id="pkl_eval-entrypoints"></a>entrypoints |  The pkl file to use as an entry point (needs to be part of the srcs). Typically a single file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_eval-expression"></a>expression |  A pkl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pkl_eval-format"></a>format |  The format of the generated file to pass when calling `pkl`. See https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval.   | String | optional |  `""`  |
| <a id="pkl_eval-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs. If `outs` is specified then individual generated files will be exposed. Otherwise, a single directory, with the name of the target, containing all generated files will be exposed. (see https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval).   | Boolean | optional |  `False`  |
| <a id="pkl_eval-no_cache"></a>no_cache |  Disable caching of packages   | Boolean | optional |  `False`  |
| <a id="pkl_eval-properties"></a>properties |  Dictionary of name value pairs used to pass in Pkl external properties. See the Pkl docs: https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="pkl_eval-use_default_shell_env"></a>use_default_shell_env |  Pass the host shell environment to the pkl eval action.<br><br>The pkl eval action uses ctx.actions.run (not run_shell). When this flag is True, the action inherits the full host environment, including PATH, HOME, and variables set via --action_env. This is a non-hermetic escape hatch for readers that depend on host-installed tools or credentials.<br><br>For pkl_test, use the env attribute or --test_env instead.   | Boolean | optional |  `False`  |


<a id="pkl_library"></a>

## pkl_library

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_library")

pkl_library(<a href="#pkl_library-name">name</a>, <a href="#pkl_library-deps">deps</a>, <a href="#pkl_library-srcs">srcs</a>, <a href="#pkl_library-data">data</a>)
</pre>

Collect Pkl sources together so they can be used by other `rules_pkl` rules.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_library-deps"></a>deps |  Other targets to include in the pkl module path when building this library. Must be pkl_* targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_library-srcs"></a>srcs |  The Pkl source files to include in this library.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="pkl_library-data"></a>data |  Files to make available in the filesystem when building this library target. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="pkl_package"></a>

## pkl_package

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_package")

pkl_package(<a href="#pkl_package-name">name</a>, <a href="#pkl_package-srcs">srcs</a>, <a href="#pkl_package-extra_flags">extra_flags</a>, <a href="#pkl_package-project">project</a>, <a href="#pkl_package-strip_prefix">strip_prefix</a>)
</pre>

Prepares a Pkl project to be published as a package as per the `pkl project package` command, using Bazel.
You should have at most one `pkl_package` rule per `pkl_project` repo rule.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_package-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_package-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_package-extra_flags"></a>extra_flags |  -   | List of strings | optional |  `[]`  |
| <a id="pkl_package-project"></a>project |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="pkl_package-strip_prefix"></a>strip_prefix |  Strip a directory prefix from the srcs.   | String | optional |  `""`  |


<a id="pkl_project_rule"></a>

## pkl_project_rule

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_project_rule")

pkl_project_rule(<a href="#pkl_project_rule-name">name</a>, <a href="#pkl_project_rule-external_resource_readers">external_resource_readers</a>, <a href="#pkl_project_rule-pkl_project_deps">pkl_project_deps</a>, <a href="#pkl_project_rule-pkl_project_file">pkl_project_file</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_project_rule-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_project_rule-external_resource_readers"></a>external_resource_readers |  Map from the label of the reader executable to its Pkl scheme name (e.g. "reader+helm"). Accepts both executable targets (go_binary, sh_binary, custom rules) and plain file targets (exports_files, http_file, gs_file). Each label is built in the exec configuration and passed to the pkl CLI as --external-resource-reader <scheme>=<path>. Two labels mapping to the same scheme is an error.<br><br>Note: readers are built for the exec platform (the machine running the build). Under cross-platform pkl_test (e.g. target platform = iOS, exec platform = Linux x86_64), the reader binary will be built for the exec platform, which may differ from the target platform. This is usually correct for readers (which run on the build host), but it means reader binaries cannot reference target-platform-specific toolchain outputs.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="pkl_project_rule-pkl_project_deps"></a>pkl_project_deps |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_pkl//pkl/private:PklProject.deps.json"`  |
| <a id="pkl_project_rule-pkl_project_file"></a>pkl_project_file |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_pkl//pkl/private:PklProject"`  |


<a id="pkl_test"></a>

## pkl_test

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_test")

pkl_test(<a href="#pkl_test-name">name</a>, <a href="#pkl_test-deps">deps</a>, <a href="#pkl_test-srcs">srcs</a>, <a href="#pkl_test-data">data</a>, <a href="#pkl_test-outs">outs</a>, <a href="#pkl_test-entrypoints">entrypoints</a>, <a href="#pkl_test-expression">expression</a>, <a href="#pkl_test-format">format</a>, <a href="#pkl_test-multiple_outputs">multiple_outputs</a>, <a href="#pkl_test-no_cache">no_cache</a>,
         <a href="#pkl_test-properties">properties</a>)
</pre>

Create a Pkl test that can be run with Bazel.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_test-deps"></a>deps |  Other targets to include in the pkl module path when building this configuration. Must be `pkl_*` targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-srcs"></a>srcs |  The Pkl source files to be evaluated.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-data"></a>data |  Files to make available in the filesystem when building this configuration. These can be accessed by relative path.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-outs"></a>outs |  Names of the output files to generate. Defaults to `<rule name>.<format>`. If the format attribute is unset, use `<rule name>.pcf`. Expects a single file if `multiple_outputs` is not set to `True`.   | List of labels; <a href="https://bazel.build/reference/be/common-definitions#configurable-attributes">nonconfigurable</a> | optional |  `[]`  |
| <a id="pkl_test-entrypoints"></a>entrypoints |  The pkl file to use as an entry point (needs to be part of the srcs). Typically a single file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="pkl_test-expression"></a>expression |  A pkl expression to evaluate within the module. Note that the `format` attribute does not affect how this renders.   | String | optional |  `""`  |
| <a id="pkl_test-format"></a>format |  The format of the generated file to pass when calling `pkl`. See https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval.   | String | optional |  `""`  |
| <a id="pkl_test-multiple_outputs"></a>multiple_outputs |  Whether to expect to render multiple file outputs. If `outs` is specified then individual generated files will be exposed. Otherwise, a single directory, with the name of the target, containing all generated files will be exposed. (see https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval).   | Boolean | optional |  `False`  |
| <a id="pkl_test-no_cache"></a>no_cache |  Disable caching of packages   | Boolean | optional |  `False`  |
| <a id="pkl_test-properties"></a>properties |  Dictionary of name value pairs used to pass in Pkl external properties. See the Pkl docs: https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |


<a id="pkl_toolchain"></a>

## pkl_toolchain

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_toolchain")

pkl_toolchain(<a href="#pkl_toolchain-name">name</a>, <a href="#pkl_toolchain-cli">cli</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="pkl_toolchain-cli"></a>cli |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="pkl_doc"></a>

## pkl_doc

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_doc")

pkl_doc(<a href="#pkl_doc-name">name</a>, <a href="#pkl_doc-srcs">srcs</a>, <a href="#pkl_doc-kwargs">**kwargs</a>)
</pre>

Generate documentation website for Pkl files.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pkl_doc-name"></a>name |  A unique name for this target.   |  none |
| <a id="pkl_doc-srcs"></a>srcs |  The Pkl source files to be documented.   |  none |
| <a id="pkl_doc-kwargs"></a>kwargs |  Further keyword arguments. E.g. visibility.   |  none |


<a id="pkl_java_library"></a>

## pkl_java_library

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_java_library")

pkl_java_library(<a href="#pkl_java_library-name">name</a>, <a href="#pkl_java_library-srcs">srcs</a>, <a href="#pkl_java_library-module_path">module_path</a>, <a href="#pkl_java_library-generate_getters">generate_getters</a>, <a href="#pkl_java_library-deps">deps</a>, <a href="#pkl_java_library-pkl_java_deps">pkl_java_deps</a>, <a href="#pkl_java_library-tags">tags</a>, <a href="#pkl_java_library-kwargs">**kwargs</a>)
</pre>

Create a compiled JAR of Java source files generated from Pkl source files.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pkl_java_library-name"></a>name |  A unique name for this target.   |  none |
| <a id="pkl_java_library-srcs"></a>srcs |  The Pkl files that are used to generate the Java source files.   |  none |
| <a id="pkl_java_library-module_path"></a>module_path |  List of Java module targets. Must export provide the JavaInfo provider.   |  `[]` |
| <a id="pkl_java_library-generate_getters"></a>generate_getters |  Generate private final fields and public getter methods instead of public final fields. Defaults to True.   |  `None` |
| <a id="pkl_java_library-deps"></a>deps |  Other targets to include in the Pkl module path when building this Java library. Must be pkl_* targets.   |  `[]` |
| <a id="pkl_java_library-pkl_java_deps"></a>pkl_java_deps |  The Pkl `java_library` targets to include in the produced Java library as deps. Must be `JavaInfo` targets. Defaults to an internal `pkl-config-java` label.   |  `[Label("@rules_pkl//pkl/private:pkl-config-java-internal")]` |
| <a id="pkl_java_library-tags"></a>tags |  Bazel tags to add to this target.   |  `[]` |
| <a id="pkl_java_library-kwargs"></a>kwargs |  Further keyword arguments. E.g. visibility.   |  none |


<a id="pkl_test_suite"></a>

## pkl_test_suite

<pre>
load("@rules_pkl//pkl:defs.bzl", "pkl_test_suite")

pkl_test_suite(<a href="#pkl_test_suite-name">name</a>, <a href="#pkl_test_suite-srcs">srcs</a>, <a href="#pkl_test_suite-deps">deps</a>, <a href="#pkl_test_suite-tags">tags</a>, <a href="#pkl_test_suite-visibility">visibility</a>, <a href="#pkl_test_suite-size">size</a>, <a href="#pkl_test_suite-test_suffix">test_suffix</a>, <a href="#pkl_test_suite-kwargs">**kwargs</a>)
</pre>

Create a suite of Pkl tests from the provided files.

Given the list of `srcs`, this macro will generate:

1. A `pkl_test` target (with visibility:private) per `src` that ends with `test_suffix`
2. A `pkl_library` that accumulates any files that don't match `test_suffix`
3. A `native.test_suite` that accumulates all of the `pkl_test` targets


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="pkl_test_suite-name"></a>name |  A unique name for this target.   |  none |
| <a id="pkl_test_suite-srcs"></a>srcs |  The source files, containing Pkl test files. Accepts files with the .pkl extension.   |  none |
| <a id="pkl_test_suite-deps"></a>deps |  Other targets to include in the Pkl module path when building this configuration. Must be pkl_* targets.   |  `None` |
| <a id="pkl_test_suite-tags"></a>tags |  Tags to add to each Pkl test target.   |  `[]` |
| <a id="pkl_test_suite-visibility"></a>visibility |  The visibility of non test Pkl source files.   |  `None` |
| <a id="pkl_test_suite-size"></a>size |  Size of Pkl test.   |  `None` |
| <a id="pkl_test_suite-test_suffix"></a>test_suffix |  A custom suffix indicating a source file is a Pkl test file.   |  `None` |
| <a id="pkl_test_suite-kwargs"></a>kwargs |  Further keyword arguments.   |  none |


