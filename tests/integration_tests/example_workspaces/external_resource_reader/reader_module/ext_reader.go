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

// ext_reader is an external resource reader for the "reader+echoext" scheme,
// living in the external reader_module Bazel module.
// It is used to verify that pkl_test correctly resolves readers from external
// repositories (short_path "../" prefix stripping).
package main

import (
	"log"
	"net/url"

	"github.com/apple/pkl-go/pkl"
)

type extReader struct{}

func (r *extReader) Scheme() string            { return "reader+echoext" }
func (r *extReader) IsGlobbable() bool         { return false }
func (r *extReader) HasHierarchicalUris() bool { return false }
func (r *extReader) ListElements(_ url.URL) ([]pkl.PathElement, error) {
	return nil, nil
}

func (r *extReader) Read(u url.URL) ([]byte, error) {
	return []byte(u.Opaque + "\n"), nil
}

func main() {
	client, err := pkl.NewExternalReaderClient(
		pkl.WithExternalClientResourceReader(&extReader{}),
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
