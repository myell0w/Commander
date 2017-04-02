// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Commander",
	dependencies: [
		.Package(url: "https://github.com/IdeasOnCanvas/Promise.git", majorVersion: 0, minor: 1)
	]
)
