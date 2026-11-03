# libs4

Pinned third-party dependencies consumed by Sapiens4 as a Git submodule.
The generated `web/remote-vendor.js` is checked in so runtime installations and
release packages do not require Node.js or npm. Building Sapiens4’s PureScript
UI from source requires the pinned compiler and Node.js; only its generated
bundles and license notices are needed at runtime.

## Browser API

Load the bundle before application code. It exposes `window.RemoteVendor`:

- `nacl`: TweetNaCl 1.0.3, including authenticated box encryption and key generation.
- `jsQR`: jsQR 1.4.0, decoding QR codes from RGBA image data.
- `QRCode`: qrcode 1.5.4, generating QR codes, including `toCanvas`.

The qrcode dependency also includes dijkstrajs 1.0.3. The complete dependency
resolution and integrity hashes are pinned in `package-lock.json`.

## Rebuild

With Node.js 22.5 or newer:

```sh
npm ci
npm run build
```

Commit dependency updates, the lockfile, regenerated bundle, and any updated
license notices together. Then update Sapiens4's `libs4` submodule commit.
Routine application changes should inspect this API and the build entrypoint
instead of reading or editing the generated bundle.

## Test and native dependencies

Language-specific packages are separate because each ecosystem needs its own
installer. Sapiens4 keeps application and test source; this repo owns the pins:

- `package.json` / `package-lock.json`: browser libraries, PureScript 0.15.16, Spago 1.0.5,
  esbuild, and sharp for icon generation. `npm ci` installs them
  into `node_modules/` here.
- `haskell/cabal.project`, `cabal.project.freeze` and `sapiens-domain.cabal`:
  application and native dependencies for GHC 9.14.1. Run `runghc build/Build.hs` from
  the consuming Sapiens4 checkout. Components read its responsibility-based
  lowercase source roots in `corpora`, `remote`, `build`, `environments` and
  `spec/support`; module names match their capitalized filenames, independently
  of directory names;
  native C bindings, vendored libsodium and dependency caches stay here.
- `purescript/spago.yaml` / `purescript/spago.lock`: PureScript package set 81.11.0
  and Halogen 7.0.0. `purescript/src/Libs4/Browser.*` contains thin browser,
  storage, networking, QR, and crypto bindings. UI state, rendering, protocol
  policy, and event handling belong to Sapiens4. The Sapiens4 build entrypoint
  compiles its `.purs` files with this workspace; downloaded packages stay in
  `purescript/.spago/` and caches in `.cache/`.
- `ruby/Gemfile` / `ruby/Gemfile.lock`: RSpec, WEBrick, and SQLite dependencies.
  From the Sapiens4 root, run `ruby submodules/libs4/ruby/bundle.rb install`, then
  `ruby submodules/libs4/ruby/bundle.rb exec rspec`. The wrapper retains the caller's working
  directory and installs gems in `ruby/.gems/` here.
- `python/*-requirements.txt`: remote client and relay requirements, also used by tests. Create a virtual environment in `python/.venv/` and install the
  relevant requirements with that interpreter. The Ruby wrapper uses this
  interpreter for tests unless `SAPIENS_PYTHON` is supplied.
- `python/package-windows.ps1`: pinned embedded Python download, checksum
  verification, and architecture-specific wheel installation for release builds.
- `dotnet/WebView2.props`: the pinned WebView2 NuGet dependency, imported by
  Sapiens4's Windows application and accessibility probe projects.

Installed packages, virtual environments, and caches remain ignored. Do not
commit them. Release builders copy the browser bundle and license notices;
Node/Ruby test dependencies are not included in the application package.

## Licenses

Bundled third-party libraries retain their original licenses; required notices
are in [license/REMOTE_DEPENDENCIES.txt](license/REMOTE_DEPENDENCIES.txt) and
[license/PURESCRIPT_DEPENDENCIES.txt](license/PURESCRIPT_DEPENDENCIES.txt).
The build integration was extracted from Sapiens4 at `70daf72` and retains its
[Sustainable Use License](license/LICENSE.md). That license does not replace
the licenses of the bundled libraries.

`tools/svg-to-ico.cjs` converts an input SVG into an ICO using the pinned Sharp dependency. Application artwork and output names remain in the consuming repository.
