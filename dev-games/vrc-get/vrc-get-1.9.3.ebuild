# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	aho-corasick@1.1.4
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.103
	async-compression@0.4.42
	async-lock@3.4.2
	async-stream-impl@0.3.6
	async-stream@0.3.6
	async_zip@0.0.18
	atomic-waker@1.1.2
	autocfg@1.5.0
	aws-lc-rs@1.18.2
	aws-lc-sys@0.46.0
	base64@0.22.1
	bitflags@2.11.1
	block-buffer@0.12.0
	bumpalo@3.20.2
	bytes@1.11.1
	cc@1.2.60
	cesu8@1.1.0
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	clap@4.6.1
	clap_builder@4.6.0
	clap_complete@4.6.7
	clap_derive@4.6.1
	clap_lex@1.1.0
	cmake@0.1.58
	color-print-proc-macro@0.3.7
	color-print@0.3.7
	colorchoice@1.0.5
	combine@4.6.7
	compression-codecs@0.4.38
	compression-core@0.4.32
	concurrent-queue@2.5.0
	const-oid@0.10.2
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	core-foundation@0.9.4
	cpufeatures@0.3.0
	crc32fast@1.5.0
	crossbeam-queue@0.3.12
	crossbeam-utils@0.8.21
	crypto-common@0.2.1
	deflate64@0.1.12
	deranged@0.5.8
	digest@0.11.2
	dirs-sys@0.5.0
	displaydoc@0.2.5
	dunce@1.0.5
	either@1.16.0
	encoding_rs@0.8.35
	enum-map-derive@0.17.0
	enum-map@2.7.3
	env_filter@2.0.0
	env_logger@0.11.11
	equivalent@1.0.2
	errno@0.3.14
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	fastrand@2.4.1
	find-msvc-tools@0.1.9
	flate2@1.1.9
	fnv@1.0.7
	foldhash@0.1.5
	foreign-types-shared@0.1.1
	foreign-types@0.3.2
	form_urlencoded@1.2.2
	fs_extra@1.3.0
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.32
	futures-lite@2.6.1
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	futures@0.3.32
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.2
	h2@0.4.13
	hashbrown@0.15.5
	hashbrown@0.17.0
	heck@0.5.0
	hex@0.4.3
	home@0.5.12
	http-body-util@0.1.3
	http-body@1.0.1
	http@1.4.0
	httparse@1.10.1
	hybrid-array@0.4.10
	hyper-rustls@0.27.9
	hyper-tls@0.6.0
	hyper-util@0.1.20
	hyper@1.9.0
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	id-arena@2.3.0
	idna@1.1.0
	idna_adapter@1.2.1
	indexmap@2.14.0
	ipnet@2.12.0
	iri-string@0.7.12
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itertools@0.15.0
	itoa@1.0.18
	jiff-static@0.2.23
	jiff@0.2.23
	jni-sys-macros@0.4.1
	jni-sys@0.3.1
	jni-sys@0.4.1
	jni@0.21.1
	jobserver@0.1.34
	js-sys@0.3.95
	lazy_static@1.5.0
	leb128fmt@0.1.0
	libc@0.2.186
	libredox@0.1.16
	linux-raw-sys@0.12.1
	litemap@0.8.2
	log@0.4.33
	lru-slab@0.1.2
	memchr@2.8.0
	mime@0.3.17
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	mio@1.2.0
	native-tls@0.2.18
	nom@7.1.3
	num-conv@0.2.1
	num-traits@0.2.19
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	openssl-macros@0.1.1
	openssl-probe@0.2.1
	openssl-src@300.6.0+3.6.2
	openssl-sys@0.9.116
	openssl@0.10.80
	opool@0.1.1
	option-ext@0.2.0
	ordered-float@2.10.1
	parking@2.2.1
	percent-encoding@2.3.2
	pin-project-internal@1.1.11
	pin-project-lite@0.2.17
	pin-project@1.1.11
	pkg-config@0.3.33
	plist@1.10.0
	portable-atomic-util@0.2.7
	portable-atomic@1.13.1
	potential_utf@0.1.5
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	prettyplease@0.2.37
	proc-macro2@1.0.106
	quick-xml@0.41.0
	quinn-proto@0.11.14
	quinn-udp@0.5.14
	quinn@0.11.9
	quote@1.0.45
	r-efi@5.3.0
	r-efi@6.0.0
	rand@0.9.4
	rand_chacha@0.9.0
	rand_core@0.9.5
	redox_users@0.5.2
	regex-automata@0.4.14
	regex-syntax@0.8.10
	regex@1.12.3
	reqwest@0.13.4
	ring@0.17.14
	rustc-hash@2.1.2
	rustix@1.1.4
	rustls-native-certs@0.8.3
	rustls-pki-types@1.14.0
	rustls-platform-verifier-android@0.1.1
	rustls-platform-verifier@0.6.2
	rustls-webpki@0.103.16
	rustls@0.23.38
	rustversion@1.0.22
	same-file@1.0.6
	schannel@0.1.29
	security-framework-sys@2.17.0
	security-framework@3.7.0
	semver@1.0.28
	serde-value@0.7.0
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	serde_path_to_error@0.1.20
	serde_repr@0.1.20
	sha1@0.11.0
	sha2@0.11.0
	shlex@1.3.0
	signal-hook-registry@1.4.8
	simd-adler32@0.3.9
	slab@0.4.12
	smallvec@1.15.1
	socket2@0.6.3
	stable_deref_trait@1.2.1
	strsim@0.11.1
	subtle@2.6.1
	syn@2.0.117
	sync_wrapper@1.0.2
	synstructure@0.13.2
	system-configuration-sys@0.6.0
	system-configuration@0.7.0
	tempfile@3.27.0
	thiserror-impl@1.0.69
	thiserror-impl@2.0.18
	thiserror@1.0.69
	thiserror@2.0.18
	thread_local@1.1.9
	time-core@0.1.8
	time-macros@0.2.27
	time@0.3.47
	tinystr@0.8.3
	tinyvec@1.11.0
	tinyvec_macros@0.1.1
	tokio-macros@2.7.0
	tokio-native-tls@0.3.1
	tokio-rustls@0.26.4
	tokio-util@0.7.18
	tokio@1.52.3
	tower-http@0.6.8
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.5.3
	tracing-core@0.1.36
	tracing@0.1.44
	try-lock@0.2.5
	typed-arena@2.0.2
	typenum@1.19.0
	unicode-ident@1.0.24
	unicode-properties@0.1.4
	unicode-xid@0.2.6
	untrusted@0.9.0
	url@2.5.8
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.23.4
	vcpkg@0.2.15
	vrc-get-litedb@0.3.0-beta.8
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.3+wasi-0.2.9
	wasip3@0.4.0+wasi-0.3.0-rc-2026-01-06
	wasm-bindgen-futures@0.4.68
	wasm-bindgen-macro-support@0.2.118
	wasm-bindgen-macro@0.2.118
	wasm-bindgen-shared@0.2.118
	wasm-bindgen@0.2.118
	wasm-encoder@0.244.0
	wasm-metadata@0.244.0
	wasm-streams@0.5.0
	wasmparser@0.244.0
	web-sys@0.3.95
	web-time@1.1.0
	webpki-root-certs@1.0.7
	winapi-util@0.1.11
	windows-collections@0.1.1
	windows-collections@0.3.2
	windows-core@0.60.1
	windows-core@0.62.2
	windows-future@0.1.1
	windows-future@0.3.2
	windows-implement@0.59.0
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.1.3
	windows-link@0.2.1
	windows-numerics@0.1.1
	windows-numerics@0.3.1
	windows-registry@0.6.1
	windows-result@0.3.4
	windows-result@0.4.1
	windows-strings@0.3.1
	windows-strings@0.5.1
	windows-sys@0.45.0
	windows-sys@0.52.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.42.2
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows-threading@0.2.1
	windows@0.60.0
	windows@0.62.2
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.42.2
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.42.2
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.42.2
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.42.2
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	winreg@0.56.0
	wit-bindgen-core@0.51.0
	wit-bindgen-rust-macro@0.51.0
	wit-bindgen-rust@0.51.0
	wit-bindgen@0.51.0
	wit-bindgen@0.57.1
	wit-component@0.244.0
	wit-parser@0.244.0
	writeable@0.6.3
	yoke-derive@0.8.2
	yoke@0.8.3
	zerocopy-derive@0.8.48
	zerocopy@0.8.48
	zerofrom-derive@0.1.7
	zerofrom@0.1.7
	zeroize@1.8.2
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zmij@1.0.21
"

RUST_MIN_VER="1.88.0"

inherit cargo shell-completion toolchain-funcs

DESCRIPTION="Open-source command-line client of VRChat Package Manager"
HOMEPAGE="https://github.com/vrc-get/vrc-get"
SRC_URI="
	https://github.com/vrc-get/vrc-get/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="experimental-vcc"

RDEPEND="app-misc/ca-certificates"

QA_FLAGS_IGNORED="usr/bin/${PN}"

src_prepare() {
	default

	# Exclude ALCOM (vrc-get-gui) and workspace helper crates so only the CLI
	# and vrc-get-vpm library are resolved and built.
	rm -r vrc-get-gui xtask || die
	sed -i \
		-e '/"xtask"/d' \
		-e '/"vrc-get-gui/d' \
		Cargo.toml || die
	cargo_update_crates
}

src_configure() {
	local myfeatures=(
		$(usev experimental-vcc)
	)

	cargo_src_configure
}

src_compile() {
	pushd vrc-get >/dev/null || die
	cargo_src_compile
	popd >/dev/null || die
}

src_test() {
	pushd vrc-get >/dev/null || die
	cargo_src_test
	popd >/dev/null || die

	local vpm_args=()
	local vpm_test_args=()
	if use experimental-vcc; then
		vpm_args+=(
			--features experimental-project-management
			--features experimental-unity-management
		)
		# Upstream test expectation is stale against current migrate() behavior
		# when settings.json is absent; upstream CI only tests default features.
		vpm_test_args+=( --skip no_settings_json )
	fi

	pushd vrc-get-vpm >/dev/null || die
	cargo_env "${CARGO}" test $(usex debug "" --release) "${vpm_args[@]}" -- "${vpm_test_args[@]}" \
		|| die "vrc-get-vpm tests failed"
	popd >/dev/null || die
}

src_install() {
	cargo_src_install --path vrc-get

	if ! tc-is-cross-compiler; then
		local bin="${ED}/usr/bin/vrc-get"
		"${bin}" completion bash > vrc-get.bash || die
		"${bin}" completion zsh > vrc-get.zsh || die
		"${bin}" completion fish > vrc-get.fish || die
		newbashcomp vrc-get.bash vrc-get
		newzshcomp vrc-get.zsh _vrc-get
		newfishcomp vrc-get.fish vrc-get.fish
	fi

	local DOCS=( CHANGELOG.md README.md )
	einstalldocs
}
