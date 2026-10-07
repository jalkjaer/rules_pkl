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

// echo_reader is an example pkl external resource reader for the "reader+echo:" scheme.
//
// It uses the official pkl-go ExternalReaderClient, which handles the pkl Message
// Passing API (https://pkl-lang.org/main/current/bindings-specification/message-passing-api.html)
// automatically — no manual msgpack encoding/framing required.
//
// The reader is wired into Bazel via:
//
//	pkl_project_rule(
//	    external_resource_readers = {"reader+echo": ":echo_reader"},
//	)
//
// Any resource URI of the form "reader+echo:<text>" returns "<text>\n" as its content.
package main

import (
	"log"
	"net/url"

	"github.com/apple/pkl-go/pkl"
)

// echoReader implements pkl.ResourceReader for the "reader+echo:" scheme.
// It returns the opaque part of the URI (everything after "reader+echo:") as the resource content.
type echoReader struct{}

func (r *echoReader) Scheme() string              { return "reader+echo" }
func (r *echoReader) IsGlobbable() bool           { return false }
func (r *echoReader) HasHierarchicalUris() bool   { return false }
func (r *echoReader) ListElements(_ url.URL) ([]pkl.PathElement, error) { return nil, nil }

func (r *echoReader) Read(u url.URL) ([]byte, error) {
	// The opaque part is everything after the "reader+echo:" prefix.
	return []byte(u.Opaque + "\n"), nil
}

func main() {
	client, err := pkl.NewExternalReaderClient(
		pkl.WithExternalClientResourceReader(&echoReader{}),
	)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()
	if err := client.Run(); err != nil {
		log.Fatal(err)
	}
}
