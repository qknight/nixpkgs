{ config, lib, pkgs, ... }:

with lib;

let

  builder = pkgs.substituteAll {
    src = ./builder.sh;
    isExecutable = true;
    inherit (pkgs) bash;
    path = [pkgs.coreutils pkgs.gnused pkgs.gnugrep];
    #firmware = pkgs.raspberrypifw;
  };

  platform = pkgs.stdenv.platform;

in

{
  options = {

    boot.loader.odroidU3.enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Whether to create files with the system generations in
        <literal>/boot</literal>.
        <literal>/boot/old</literal> will hold files from old generations.
      '';
    };

  };

  config = mkIf config.boot.loader.odroidU3.enable {
    system.build.installBootLoader = builder;
    system.boot.loader.id = "odroidU3";
    system.boot.loader.kernelFile = platform.kernelTarget;
  };
}
