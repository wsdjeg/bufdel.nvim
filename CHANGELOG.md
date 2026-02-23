# Changelog

## [2.0.0](https://github.com/wsdjeg/bufdel.nvim/compare/v1.1.0...v2.0.0) (2026-02-23)


### ⚠ BREAKING CHANGES

* rename `BufDelPro` to `BufDelPre`

### Features

* add bufdel logger ([985faac](https://github.com/wsdjeg/bufdel.nvim/commit/985faacae422a50641cacec3a6d0f9a204d70fc8))
* add switch option ([d267809](https://github.com/wsdjeg/bufdel.nvim/commit/d26780969b1aff62b48e9ea8d9acd106718980a4))
* lazy load function ([468bd48](https://github.com/wsdjeg/bufdel.nvim/commit/468bd48a958d0dff868cf8c9764c41097e31e6d6))
* support string argument ([937263c](https://github.com/wsdjeg/bufdel.nvim/commit/937263cdd65986125c97f510fba982bb4e028750))


### Bug Fixes

* fix cmd_to_buffers function ([e4939c8](https://github.com/wsdjeg/bufdel.nvim/commit/e4939c820b2776af8083b82db2350aab614bc476))
* rename `BufDelPro` to `BufDelPre` ([c45a2b1](https://github.com/wsdjeg/bufdel.nvim/commit/c45a2b10857ca9106dd4d071716d5e2f4bf5c2d7))
* skip empty buffer list ([15b2149](https://github.com/wsdjeg/bufdel.nvim/commit/15b2149850c068166d3b9e019f9fb72703a74208))
* update release-please action ([a72bc6a](https://github.com/wsdjeg/bufdel.nvim/commit/a72bc6abb97f1492f80df64a3682e75aa1626a4b))
* use lastused as default switch ([7b9346b](https://github.com/wsdjeg/bufdel.nvim/commit/7b9346bc676430b03620ef6aca60e7c39d938100))
* use lastused as default switch ([8249db5](https://github.com/wsdjeg/bufdel.nvim/commit/8249db590d9c8b33e265ac825221dce3378d4aab))
* use opt.switch as number ([dd96964](https://github.com/wsdjeg/bufdel.nvim/commit/dd96964a9a5b7e54ea1113d8a43110e4e634b60b))

## [1.1.0](https://github.com/wsdjeg/bufdel.nvim/compare/v1.0.1...v1.1.0) (2025-12-01)


### Features

* add user autocmds ([4fe7b02](https://github.com/wsdjeg/bufdel.nvim/commit/4fe7b02685bc44edd254caac6d745146e914ca4e))
* change alt_buf in finded windows ([55b4be7](https://github.com/wsdjeg/bufdel.nvim/commit/55b4be7455a1ad2f63998b459deead27aa2c564a))
* handle terminal buffer ([cb2f5f6](https://github.com/wsdjeg/bufdel.nvim/commit/cb2f5f6d36dc26f0688bed97181c2b990475e4ce))
* support command-range ([d2006e3](https://github.com/wsdjeg/bufdel.nvim/commit/d2006e311c3429bce53331e7671e8c8f140c5f8c))


### Bug Fixes

* add stylua configure ([95fb550](https://github.com/wsdjeg/bufdel.nvim/commit/95fb550442aa0e37c3c3ed98cba8457dcc0bdb60))
* annotations added, reworked conditionals, EOF comment ([492a898](https://github.com/wsdjeg/bufdel.nvim/commit/492a898dc7c556d810e50989773123a7a6d4b26f))
* fix bufdel logic ([7a47727](https://github.com/wsdjeg/bufdel.nvim/commit/7a47727e21599406f8457008442bfc12c0c71add))
* fix modified buffer logic ([cb404f0](https://github.com/wsdjeg/bufdel.nvim/commit/cb404f047a743994c377d00c14e2557bdbccc51c))
* fix table&lt;integer&gt; support ([2e8709d](https://github.com/wsdjeg/bufdel.nvim/commit/2e8709de71c994b649f920e188086a333ab36329))
* handle nvim_buf_delete error ([8dfa8d8](https://github.com/wsdjeg/bufdel.nvim/commit/8dfa8d81d0a4466965f5a842a0cb1a7af6e2faaa))
* skip winfixbuf window and no exists buf ([3d4ec5e](https://github.com/wsdjeg/bufdel.nvim/commit/3d4ec5e146cceddf2e8f5d1d0c7170539cfe976c))
* **stylua:** added `LuaJIT` syntax and formatted code ([a5b9833](https://github.com/wsdjeg/bufdel.nvim/commit/a5b9833b9e1a48875af723b9f6fac9c07592ff34))
* use `vim.cmd.mode()` to clear cmdline ([4c76f57](https://github.com/wsdjeg/bufdel.nvim/commit/4c76f57e6090a76808ce3cbbb5b219aa22ac320a))
* use redraw to clear cmdline ([8e55fcf](https://github.com/wsdjeg/bufdel.nvim/commit/8e55fcfe5ecdae901dcb580b31c2e7a83adbc97b))

## [1.0.1](https://github.com/wsdjeg/bufdel.nvim/compare/v1.0.0...v1.0.1) (2025-11-30)


### Bug Fixes

* add readme ([03d7f0c](https://github.com/wsdjeg/bufdel.nvim/commit/03d7f0c3e471edb7afdce8c8657887205f27129d))

## 1.0.0 (2025-11-30)


### Bug Fixes

* add delete_buf function ([d573326](https://github.com/wsdjeg/bufdel.nvim/commit/d573326328a4c65f7f251c06ceff48b269b1a76d))
* fix bufdel ([6fae8b7](https://github.com/wsdjeg/bufdel.nvim/commit/6fae8b75cd5bd8b459e1d9d49ee51a224f6c7862))
