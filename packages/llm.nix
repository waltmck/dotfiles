{
  pkgs,
  lib,
  ...
}: {
  # CLIENT
  home-manager.sharedModules = [
    {
      xdg.configFile."com.jeffser.Alpaca/server.json" = {
        text = builtins.toJSON {
          remote_url = "http://127.0.0.1:11434";
          remote_bearer_token = "";

          run_remote = true;
          local_port = 11435;
          run_on_background = false;
          powersaver_warning = false;
          model_tweaks = {
            temperature = 0.7;
            seed = 0;
            keep_alive = 5;
          };
          ollama_overrides = {};
          idle_timer = 0;
        };
      };
    }
  ];

  environment.systemPackages = with pkgs; [alpaca];

  environment.persistence."/nix/state".users.waltmck.directories = [
    ".local/share/com.jeffser.Alpaca"
    ".cache/com.jeffser.Alpaca"
  ];

  # SERVER

  services.ollama = {
    enable = true;
    loadModels = [
      # "llama3.1:70b"
      "llama3.1" # Macbook Air doesn't have enough memory to run 70b model
    ];
  };

  environment.persistence."/nix/state".directories = [
    {
      directory = "/var/lib/private/ollama";
      user = "ollama";
      group = "ollama";
      mode = "755";
    }
  ];
}
