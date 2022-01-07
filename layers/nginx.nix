{ ... }:

{
  services.nginx = {
    enable = true;

    # Default (hardcoded) in recent nixpkgs
    #types_hash_max_size 4096;
    appendHttpConfig = ''
      sendfile on;
      server_names_hash_bucket_size 128;
    '';
  };
}
