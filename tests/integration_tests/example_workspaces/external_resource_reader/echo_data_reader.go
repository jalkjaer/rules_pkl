// Copyright © 2024-2026 Apple Inc. and the Pkl project authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// echo_data_reader is an example external resource reader for the
// "reader+echodata:" scheme. Unlike echo_reader it has a data dependency: it
// reads reader_prefix.txt from its own runfiles (declared in `data` on the
// go_binary) and prepends the content to every resource it returns.
//
// The file is located with the rules_go runfiles library. That library works
// both when Bazel stages the reader's own <exe>.runfiles tree (pkl_eval) and
// when the reader's runfiles are merged into a test's runfiles (pkl_test).
//
// The lookup happens in Read(), not at startup, so a missing data file is
// reported to Pkl as an evaluation error instead of killing the reader process.
package main

import (
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"

	"github.com/apple/pkl-go/pkl"
	"github.com/bazelbuild/rules_go/go/runfiles"
)

type dataReader struct{}

func (r *dataReader) Scheme() string            { return "reader+echodata" }
func (r *dataReader) IsGlobbable() bool         { return false }
func (r *dataReader) HasHierarchicalUris() bool { return false }
func (r *dataReader) ListElements(_ url.URL) ([]pkl.PathElement, error) {
	return nil, nil
}

func (r *dataReader) Read(u url.URL) ([]byte, error) {
	rf, err := runfiles.New()
	if err != nil {
		return nil, fmt.Errorf("echo_data_reader: initializing runfiles: %w", err)
	}
	path, err := rf.Rlocation("_main/reader_prefix.txt")
	if err != nil {
		return nil, fmt.Errorf("echo_data_reader: locating reader_prefix.txt: %w", err)
	}
	prefix, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("echo_data_reader: reading reader_prefix.txt: %w", err)
	}
	return []byte(strings.TrimRight(string(prefix), "\r\n") + u.Opaque + "\n"), nil
}

func main() {
	client, err := pkl.NewExternalReaderClient(
		pkl.WithExternalClientResourceReader(&dataReader{}),
	)
	if err != nil {
		log.Fatal(err)
	}
	// Run() blocks until the client has been closed by pkl's close message, so
	// no deferred client.Close() here: a second close panics.
	if err := client.Run(); err != nil {
		log.Fatal(err)
	}
}
