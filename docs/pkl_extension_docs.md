<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Module extension for using rules_pkl with bzlmod.

<a id="pkl"></a>

## pkl

<pre>
pkl = use_extension("@rules_pkl//pkl/extensions:pkl.bzl", "pkl")
pkl.project(<a href="#pkl.project-name">name</a>, <a href="#pkl.project-environment">environment</a>, <a href="#pkl.project-external_resource_readers">external_resource_readers</a>, <a href="#pkl.project-extra_flags">extra_flags</a>, <a href="#pkl.project-pkl_project">pkl_project</a>,
            <a href="#pkl.project-pkl_project_deps">pkl_project_deps</a>)
pkl.install(<a href="#pkl.install-version">version</a>)
</pre>


**TAG CLASSES**

<a id="pkl.project"></a>

### project

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl.project-name"></a>name |  Name of the workspace to generate   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `""`  |
| <a id="pkl.project-environment"></a>environment |  Dictionary of name value pairs used to pass in Pkl env vars. See the Pkl docs: https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="pkl.project-external_resource_readers"></a>external_resource_readers |  Map from the Bazel label of the reader executable to its Pkl scheme name (e.g. "reader+helm"). Every pkl_eval/pkl_test that depends on `@<name>//:packages` automatically receives `--external-resource-reader <scheme>=<path>` with no further configuration.<br><br>Labels are resolved in the caller's module context, so apparent labels work:<br><br>    external_resource_readers = {         "//:my_reader": "reader+helm",     }   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="pkl.project-extra_flags"></a>extra_flags |  Dictionary of name value pairs used to pass in Pkl external flags. See the Pkl docs: https://pkl-lang.org/main/current/pkl-cli/index.html#command-eval   | List of strings | optional |  `[]`  |
| <a id="pkl.project-pkl_project"></a>pkl_project |  The PklProject file   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="pkl.project-pkl_project_deps"></a>pkl_project_deps |  The PklProject.deps.json file   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |

<a id="pkl.install"></a>

### install

Override the default Pkl version to be used

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="pkl.install-version"></a>version |  Version to install   | String | required |  |


