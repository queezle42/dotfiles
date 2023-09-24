{ config, lib, pkgs, ... }:
with lib;

let
  json = pkgs.formats.json {};
  cfg = config.queezle.audio;
in {
  options.queezle.audio = {
    enable = mkEnableOption "audio";
    pipewire = mkEnableOption "pipewire";
    network.sender.enable = mkEnableOption "network-sender";
    network.sender.tsubo.enable = mkEnableOption "network-sender to tsubo";
    network.receiver.enable = mkOption {
      type = types.bool;
      default = config.queezle.qnet.enable;
    };
    surround51 = mkEnableOption "5.1 surround hardware configuration";
  };

  config = mkIf (cfg.enable && cfg.pipewire) {

    # rtkit is optional but recommended
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      systemWide = true;

      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Start pipewire so network streams are available even when no user is logged in
    systemd.services.pipewire.wantedBy = [ "multi-user.target" ];


    environment.etc."pipewire/pipewire.conf.d/50-proxy-sink.conf" = {
      text = ''
        "context.modules" = [
          {
            name = "libpipewire-module-loopback"
            args = {
              node.description = "Output proxy (stereo)"
              audio.rate = 48000
              audio.position = "FL,FR"
              capture.props = {
                node.name = "output-proxy-stereo"
                media.class = "Audio/Sink"
              }
              playback.props = {
                node.name = "output-proxy-stereo-playback"
                node.description = "Output proxy (stereo) playback"
                node.passive = true
                # Fix error on stargate ("ERR" column in pw-top accumulating errors, no audio) (enabled again, maybe that fixes the stuttering bug?)
                stream.dont-remix = true
              }
            }
          }
        ]
      '';
    };

    environment.etc."pipewire/pipewire.conf.d/51-proxy-source.conf" = {
      text = ''
        context.modules = [
          {
            name = "libpipewire-module-loopback"
            args = {
              node.description = "Input proxy"
              capture.props = {
                node.name = "input-proxy-capture"
                node.description = "Input proxy capture"
                node.passive = true
                audio.position = "MONO"
              }
              playback.props = {
                node.name = "input-proxy"
                media.class = "Audio/Source"
                audio.position = "MONO"
              }
            }
          }
        ]
      '';
    };

    environment.etc."pipewire/pipewire.conf.d/52-proxy-sink-surround51.conf" = mkIf cfg.surround51 {
      text = ''
        context.modules = [
          {
            name = "libpipewire-module-loopback",
            args = {
              node.description = "Output proxy (5.1)",
              audio.channels = 6,
              audio.position = [ FL FR FC LFE RL RR ],
              audio.rate = 48000,
              capture.props = {
                node.name = "output-proxy-5.1",
                media.class = "Audio/Sink",
              },
              playback.props = {
                node.name = "output-proxy-5.1-playback",
                node.description = "Output proxy (5.1) playback",
                node.passive = true,
                target.object = "aureon-xfire-5.1",
              },
            },
          }
        ]
      '';
    };

    environment.etc."pipewire/pipewire.conf.d/53-upmix.conf" = mkIf cfg.surround51 {
      text = ''
        context.modules = [
          { name = libpipewire-module-filter-chain
            args = {
              node.description = "5.1 upmix"
              media.name       = "5.1 upmix"
              filter.graph = {
                nodes = [
                  { name = copyIL type = builtin label = copy }
                  { name = copyOL type = builtin label = copy }
                  { name = copyORL type = builtin label = copy }
                  { name = copyIR type = builtin label = copy }
                  { name = copyOR type = builtin label = copy }
                  { name = copyORR type = builtin label = copy }
                  { name = copyOC type = builtin label = copy }
                  {
                    name   = mix
                    type   = builtin
                    label  = mixer
                    control = {
                      "Gain 1" = 0.3
                      "Gain 2" = 0.3
                    }
                  }
                  {
                    type  = builtin
                    name  = lpLFE
                    label = bq_lowpass
                    control = { "Freq" = 150.0 }
                  }
                ]
                links = [
                  { output = "copyIL:Out" input = "copyOL:In" }
                  { output = "copyIL:Out" input = "copyORL:In" }
                  { output = "copyIR:Out" input = "copyOR:In" }
                  { output = "copyIR:Out" input = "copyORR:In" }
                  { output = "copyIL:Out" input = "mix:In 1" }
                  { output = "copyIR:Out" input = "mix:In 2" }
                  { output = "mix:Out" input = "lpLFE:In" }
                  { output = "mix:Out" input = "copyOC:In" }
                ]
                inputs  = [ "copyIL:In" "copyIR:In" ]
                outputs = [ "copyOL:Out" "copyOR:Out" "copyOC:Out" "lpLFE:Out" "copyORL:Out" "copyORR:Out"]
              }
              capture.props = {
                node.name         = "output-proxy-upmix-5.1"
                audio.position    = [ FL FR ]
                media.class       = "Audio/Sink"
              }
              playback.props = {
                node.name         = "output-proxy-5.1"
                audio.position    = [ FL FR FC LFE RL RR ]
                stream.dont-remix = true
                node.passive      = true
                target.object = "output-proxy-5.1",
              }
            }
          }
        ]
      '';
    };

    environment.etc."pipewire/pipewire.conf.d/90-network-receiver-roc.conf" = mkIf cfg.network.receiver.enable {
      text = ''
        context.modules = [
          {
            name = "libpipewire-module-roc-source"
            args = {
              local.ip = "::"
              resampler.profile = "medium"
              fec.code = "rs8m"
              sess.latency.msec = "50"
              local.source.port = 10001
              local.repair.port = 10002
              source.name = "ROC source"
              source.props = {
                node.name = "roc-source"
                node.description = "ROC source"
                audio.position = "FL,FR"
                target.object = "output-proxy-stereo"
              }
            }
          }
        ]
      '';
    };

    networking.nftables.firewall.rules.qnet-audio = mkIf cfg.network.receiver.enable {
      from = [ "qnet-jens-trusted" ];
      to = [ "fw" ];
      allowedUDPPorts = [ 10001 10002 ];
    };

    environment.etc."pipewire/pipewire.conf.d/90-network-receiver-surround51.conf" = mkIf (cfg.network.receiver.enable && cfg.surround51) {
      text = ''
        context.modules = [
          {
            name = libpipewire-module-rtp-source
            args = {
              source.ip = "::"
              source.port = 10003
              sess.latency.msec = 50
              audio.channels = 6
              audio.position = [ FL FR FC LFE RL RR ]
              stream.props = {
                node.name = "rtp-source-surround51"
                node.description = "RTP source (5.1)"

                # Setting 'node.passive = true' breaks playback when this is the
                # only active stream.

                # Fails when not attached to a target object during initialisation
                target.object = "output-proxy-5.1"
              }
            }
          }
        ]
      '';
    };

    networking.nftables.firewall.rules.qnet-audio-surround51 = mkIf (cfg.network.receiver.enable && cfg.surround51) {
      from = [ "qnet-jens-trusted" ];
      to = [ "fw" ];
      allowedUDPPorts = [ 10003 ];
    };

    environment.etc."pipewire/pipewire.conf.d/90-network-sender.conf" = mkIf cfg.network.sender.enable {
      text = ''
        context.modules = [
          {
            name = libpipewire-module-roc-sink
            args = {
              local.ip = "::"
              fec.code = "rs8m"
              remote.ip = "fd42:2a03:99:ec13::1"
              remote.source.port = 10001
              remote.repair.port = 10002
              sink.props = {
                node.name = "output-roc-stargate"
                node.description = "ROC stargate"
              }
            }
          }
        ];
      '';
    };

    environment.etc."pipewire/pipewire.conf.d/90-network-tsubo.conf" = mkIf cfg.network.sender.tsubo.enable {
      text = ''
        "context.modules" = [
          {
            name = "libpipewire-module-roc-sink"
            args = {
              "local.ip" = "10.0.2.1"
              "fec.code" = "disable"
              "remote.ip" = "10.0.2.200"
              "remote.source.port" = 10001
              #"remote.repair.port" = 10002
              "sink.name" = "ROC Sink tsubo"
              "sink.props" = {
                "node.name" = "roc-sink-tsubo"
                "node.description" = "ROC Sink tsubo"
              }
            }
          }
        ]
      '';
    };


    #systemd.services.wireplumber.environment.WIREPLUMBER_DEBUG = "3";

    environment.systemPackages = [
      pkgs.helvum
      pkgs.pulsemixer
      pkgs.pulseaudio
      pkgs.alsa-utils
      pkgs.roc-toolkit
    ];
  };
}
