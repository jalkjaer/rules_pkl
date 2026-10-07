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

// echo_reader is an example external resource reader for the "reader+echo:" and
// "reader+echofile:" schemes, used in the external_resource_reader integration test.
//
// It uses the official pkl-go ExternalReaderClient, which handles the pkl Message
// Passing API (https://pkl-lang.org/main/current/bindings-specification/message-passing-api.html)
// automatically — no manual msgpack encoding/framing required.
//
// Wiring into Bazel via pkl.project() in MODULE.bazel:
//
//	pkl.project(
//	    name = "echo_reader_project",
//	    external_resource_readers = {
//	        "//:echo_reader": "reader+echo",
//	        "//:echo_reader_plain": "reader+echofile",
//	    },
//	    pkl_project = "//:PklProject",
//	    pkl_project_deps = "//:PklProject.deps.json",
//	)
//
// Any resource URI of the form "reader+echo:<text>" or "reader+echofile:<text>"
// returns "<text>\n" as its content.
package main

import (
	"log"
	"net/url"

	"github.com/apple/pkl-go/pkl"
)

// echoReader implements pkl.ResourceReader for a given scheme.
// It returns the opaque part of the URI as the resource content.
type echoReader struct{ scheme string }

func (r *echoReader) Scheme() string            { return r.scheme }
func (r *echoReader) IsGlobbable() bool         { return false }
func (r *echoReader) HasHierarchicalUris() bool { return false }
func (r *echoReader) ListElements(_ url.URL) ([]pkl.PathElement, error) {
	return nil, nil
}

func (r *echoReader) Read(u url.URL) ([]byte, error) {
	// The opaque part is everything after the scheme prefix.
	return []byte(u.Opaque + "\n"), nil
}

func main() {
	client, err := pkl.NewExternalReaderClient(
		// "reader+echo" scheme: used by the go_binary executable target.
		pkl.WithExternalClientResourceReader(&echoReader{scheme: "reader+echo"}),
		// "reader+echofile" scheme: used by the plain-file (genrule copy) target.
		// Registering both here means the same binary serves both schemes when
		// invoked under either --external-resource-reader flag value.
		pkl.WithExternalClientResourceReader(&echoReader{scheme: "reader+echofile"}),
	)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()
	if err := client.Run(); err != nil {
		log.Fatal(err)
	}
}
