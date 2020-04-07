{ lib, pkgs, ... }:

{
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  gtk.iconCache.enable = true;

  users.users.wine = {
    isNormalUser = true;
    uid = 1101;
    passwordFile = "/etc/secrets/passwords/steam";
    extraGroups = [ "audio" "input" ];
    packages = with pkgs; [
      (wine.override {
        wineBuild = "wineWow";
        wineRelease = "stable";
        pulseaudioSupport = true;
        pngSupport = true;
        jpegSupport = true;
        colorManagementSupport = true;
        openalSupport = true;
        tiffSupport = true;
        vaSupport = true;
        fontconfigSupport = true;
        alsaSupport = true;
        xineramaSupport = true;
        vulkanSupport = true;
        sdlSupport = true;
        gstreamerSupport = true;
        openclSupport = true;
        openglSupport = true;
      })
      lutris
    ];
  };

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
  ];
}
