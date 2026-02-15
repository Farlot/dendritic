# modules/ckb.nix
{
  # We are declaring a module that the flake will export.
  # Other people (or your own hosts) can import this via your flake outputs!
  flake.nixosModules.ckb = { pkgs, lib, ... }: {
    
    # 1. Apply your custom overlay
    nixpkgs.overlays = [
      (final: prev: {
        ckb-next = prev.ckb-next.overrideAttrs (oldAttrs: rec {
          src = pkgs.fetchgit {
            url = "https://github.com/ckb-next/ckb-next";
            rev = "677749020edb3272d379c103c956b6933a59fbb5";
            sha256 = "1aas7i79gfd9aab31m7sgzfmq0kznp3035ml8jn73vrzzifb28dp";
          };
          cmakeFlags = [ "-DUSE_DBUS_MENU=0" ] ++ oldAttrs.cmakeFlags;
        });
      })
    ];

    # 2. Automatically enable the hardware daemon when this module is used
    hardware.ckb-next.enable = lib.mkDefault true;
  };
}
