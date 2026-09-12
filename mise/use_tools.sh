#!/usr/bin/env bash
# ========
# Web
# ========
mise use -g \
  node@26 \
  pnpm
mise settings add idiomatic_version_file_enable_tools node
mise settings set npm.shell_out true
mise settings set npm.package_manager pnpm
mise use -g \
  'npm:@olrtg/emmet-language-server' \
  # typescript v7 language server could be run as `tsc --lsp --stdio`
  'npm:typescript'
  superhtml

# ========
# Python
# ========
mise use -g python@3.12
MISE_PYTHON_COMPILE=0
MISE_PYTHON_PRECOMPILED_FLAVOR="freethreaded+pgo+lto-full"
mise use -g python[patch_sysconfig=false]@3
mise use -g uv pyright
mise sync python --uv
mise settings add idiomatic_version_file_enable_tools python
mise settings set python.uv_venv_auto source

# ========
# Go
# ========
mise use -g \
  go \
  go:golang.org/x/tools/gopls

# ========
# Rust
# ========
mise use -g \
  --tool-option components=rust-analyzer \
  rust

# ========
# Racket
# ========
mise use -g racket

# ========
# Lua
# ========
mise use -g \
  luajit \
  lua-language-server
echo "You should install 'luarocks' mannually if you need it"

# ========
# Protobuf
# ========
mise use -g \
  buf \
  protoc

# ---- go ----
mise use -g \
  protoc-gen-go \
  protoc-gen-go-grpc

# ---- js ----
mise use -g protoc-gen-js


# ========
# SETTINGS
# ========
mise settings set experimental true
