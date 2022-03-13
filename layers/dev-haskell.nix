{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    haskellPackages.hoogle
    #haskellPackages.threadscope
  ];

  services.hoogle = {
    enable = true;
    packages = hp: with hp; [
      hashable
      heaps
      network
      #quasar
      #quasar-network
      unordered-containers
    ];
  };
}
