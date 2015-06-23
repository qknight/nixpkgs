# untested code
{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.idsuEye;

{

  ###### interface

  options = {
    services.idsuEye = {
      enable = mkOption {
        default = false;
        description = "Whether to enable idsuEyed";
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

  users.extraGroups = singleton { 
    name = "idsuEye";
    gid = config.ids.gids.idsuEye;
  };

  jobs.idsuEye = { 
    description = "Disnix server";
    startOn = "started network-interfaces";
    wantedBy = [ "multi-user.target" ];
  };
  daemonType = "fork";
  exec = ''
    ${pkgs.idsuEye}/bin/ueyeusbd -c ${pkgs.writeText "idsuEye_config" cfg.extraConfig}
  '';

  services.cntlm.extraConfig = ''
    ;ueyed configuration file 
  '';

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="1409", OWNER="ueyed", GROUP="ueye", MODE="0660"
    SUBSYSTEM=="usb_device", ATTRS{idVendor}=="1409", OWNER="ueyed", GROUP="ueye", MODE="0660"
    SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1409", SYMLINK+="ueye/%m__%k__%s{idProduct}", RUN+="${pkgs.idsuEye}/bin/ueyenotify -F usb -f %r/ueye/%m__%k__%s{idProduct}"
    SUBSYSTEM=="usb_device", ACTION=="add", ATTRS{idVendor}=="1409", SYMLINK+="ueye/%m__%k__%s{idProduct}", RUN+="${pkgs.idsuEye}/bin/ueyenotify -F usb -f %r/ueye/%m__%k__%s{idProduct}"
    SUBSYSTEM=="usb", ACTION=="remove", ENV{DEVTYPE}=="usb_device", RUN+="${pkgs.idsuEye}/bin/ueyenotify -F usb"
  '';

}
