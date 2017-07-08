{pkgs_ ? import <nixpkgs> {}, ...}:
let
  pkgs = import (fetchTarball
    "https://github.com/NixOS/nixpkgs-channels/archive/26625c928be8ce503b23f5302222bdcb380a4445.tar.gz"
  ) {};
  terraform_pkg = pkgs.terraform.override {
    buildGoPackage = pkgs.buildGo18Package;
  };
  terraform = terraform_pkg.overrideDerivation (old: rec {
    version = "0.9.3";
    name = "terraform-${version}";
    rev = "v${version}";
    src = pkgs.fetchFromGitHub {
      inherit rev;
      owner = "hashicorp";
      repo = "terraform";
      sha256 = "00z72lwv0cprz1jjy0cr8dicl00zwc1zwsxzjssqnq0187sswkxw";
    };
  });