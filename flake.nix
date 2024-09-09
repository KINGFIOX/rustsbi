{
  description = "Rust development environment with Clang and LLVM support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        lib = pkgs.lib;
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            toolchain
            pkg-config
            clang_16
            llvm_16
            libxml2
            cargo-binutils
            (with pkgsCross.riscv64-embedded; [
              buildPackages.gcc
              buildPackages.gdb
            ])
            qemu
          ];
          RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
          MAKEFLAGS = "-j$(nproc)";
          RUST_GDB = "riscv64-none-elf-gdb";
        };
      });
}
