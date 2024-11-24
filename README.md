# Xxhash.

a pure zig implementation of [xxhash](https://github.com/Cyan4973/xxHash) (fork of [clownpriest/xxhash](https://github.com/clownpriest/xxhash))

Adapted for zig 0.14dev and Bun ffi

## usage
see test/test.zig for usage examples

## test

```bash
zig build test --summary all
```

## build

Prebuilt libs in libs folder.

to build it yourself, run:

- win: `build.bat`
- linux: `build.sh`