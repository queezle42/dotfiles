{ ... }:

{
  services.nginx = {
    enable = true;

    appendHttpConfig = ''
      sendfile on;
      keepalive_timeout 65;
      types_hash_max_size 4096;
      server_names_hash_bucket_size 128;
    '';
  };
}
