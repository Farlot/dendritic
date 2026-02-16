{ inputs, ... }:

{
  # Expose the AI stack as a reusable flake module!
  flake.nixosModules.ollama = { config, pkgs, lib, ... }: {
    
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      loadModels = [ "deepseek-r1:latest" "deepseek-r1:14b" "deepseek-r1:32b" "gpt-oss:latest" "aeline/halo:latest" ];
      # acceleration = "cuda"; # Uncomment for NVIDIA
      # acceleration = "rocm"; # Uncomment for AMD
    };

    # Optional: Add a web interface (ChatGPT-like)
    services.open-webui = {
      enable = true;
      port = 8080;
      environment = {
        # Tell Open WebUI to use SearXNG for web searches
        ENABLE_RAG_WEB_SEARCH = "True";
        RAG_WEB_SEARCH_ENGINE = "searxng";
        SEARXNG_QUERY_URL = "http://127.0.0.1:8888/search?q=<query>";
      };
    };

    sops.secrets."searx-key" = {
      owner = "searx";
    };

    services.searx = {
      enable = true;
      package = pkgs.searxng; # Use the modern 'ng' version
      redisCreateLocally = true; # Improves performance
      environmentFile = config.sops.secrets."searx-key".path;
      settings = {
        server.port = 8888;
        server.bind_address = "127.0.0.1";
        # Ensure JSON output is enabled for the LLM to read
        search.formats = [ "html" "json" ];
        engines = [
          # Dark web scraping
          { name = "ahmia"; disabled = true; }
          { name = "torch"; disabled = true; }
          # Search engines
          { name = "google"; engine = "google"; }
          { name = "duckduckgo"; engine = "duckduckgo"; }
        ];
      };
    };

  };
}
