{ pkgs, ... }: {
  amogus = pkgs.callPackage ./amogus { };
  yuzu = pkgs.callPackage ./yuzu { };
}
