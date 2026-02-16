{ inputs, ... }:

{
  # Expose your custom scripts as a reusable flake module!
  flake.homeManagerModules.scripts = { config, pkgs, lib, username, ... }: {

    home.packages = [
      (pkgs.writeShellApplication {
        name = "comfy-vault"; # Open vault for use with ComfyUI
        runtimeInputs = [ pkgs.gocryptfs pkgs.libnotify pkgs.util-linux ];
        text = ''
            # 1. Check if mounted
            if ! mountpoint -q "/mnt/spin/vault"; then
              echo "🔐 Vault is locked. Please enter password to mount..."
              notify-send "Vault" "Mounting required for ComfyUI"

              # This will prompt for password in the current terminal
              if ! gocryptfs "/mnt/spin/.vault_encrypted" "/mnt/spin/vault"; then
                echo "❌ Failed to mount vault. Exiting."
                exit 1
              fi
            fi

            # 2. Check if the specific data directory exists inside the vault
            if [ ! -d "/mnt/spin/vault/comfyuidata" ]; then
              echo "⚠️ Warning: Data directory not found at /mnt/spin/vault/comfyuidata"
              echo "Creating it now..."
              mkdir -p "/mnt/spin/vault/comfyuidata"
            fi

            # 3. Symlink models
            MODELS_DIR="/mnt/spin/vault/stablediff/models"
            TARGET_DIR="/mnt/spin/vault/comfyuidata/models/checkpoints"

            mkdir -p "$MODELS_DIR"
            if [ ! -L "$TARGET_DIR" ]; then
              rm -rf "$TARGET_DIR" # Remove directory if it's not a link
              ln -s "$MODELS_DIR" "$TARGET_DIR"
            fi

            # 4. Launch ComfyUI
            echo "🚀 Launching ComfyUI..."
            comfy-ui --base-directory "/mnt/spin/vault/comfyuidata"
            '';
            })

            (pkgs.writeShellApplication {
            name = "webui-vault"; # Open vault for use with WebUI
            runtimeInputs = [ pkgs.gocryptfs pkgs.libnotify pkgs.util-linux ];
            text = ''
            # 1. Check if mounted
            if ! mountpoint -q "/mnt/spin/vault"; then
              echo "🔐 Vault is locked. Please enter password to mount..."
              notify-send "Vault" "Mounting required for SD-WebUI"

              if ! gocryptfs "/mnt/spin/.vault_encrypted" "/mnt/spin/vault"; then
                echo "❌ Failed to mount vault. Exiting."
                exit 1
              fi
            fi

            # 2. Check/Create data directory
            if [ ! -d "/mnt/spin/vault/webuidata" ]; then
              echo "Creating data directory at /mnt/spin/vault/webuidata..."
              mkdir -p "/mnt/spin/vault/webuidata"
            fi

            # 3. Symlink models
            MODELS_DIR="/mnt/spin/vault/stablediff/models"
            TARGET_DIR="/mnt/spin/vault/webuidata/models/Stable-diffusion"

            mkdir -p "$MODELS_DIR"
            if [ ! -L "$TARGET_DIR" ]; then
              rm -rf "$TARGET_DIR" # Remove directory if it's not a link
              ln -s "$MODELS_DIR" "$TARGET_DIR"
            fi

            # 3. Launch WebUI
            echo "🚀 Launching Stable Diffusion WebUI..."
            stable-diffusion-webui --data-dir "/mnt/spin/vault/webuidata"
            '';
            })

            # Ping waybar Script
            (pkgs.writeShellApplication {
            name = "waybar-ping";
            runtimeInputs = [ pkgs.iputils pkgs.bc pkgs.gnugrep pkgs.gawk ];
            text = ''
            # Ping 3 times, wait 1s between pings
            PING_OUT=$(ping -c 3 -W 1 8.8.8.8 2>/dev/null || true)
            AVG_LATENCY=$(echo "$PING_OUT" | tail -1 | awk -F'/' '{print $5}')

            if [ -z "$AVG_LATENCY" ]; then
              echo '{"text": "󰈂 Down", "tooltip": "No connection to 8.8.8.8", "class": "down"}'
            else
              LOSS=$(echo "$PING_OUT" | grep "packet loss" | awk -F'%' '{print $1}' | awk '{print $NF}')
              ROUNDED_LATENCY=$(echo "''${AVG_LATENCY}" | awk '{print int($1 + 0.5)}')
              TEXT="󰓅 ''${ROUNDED_LATENCY}ms | ''${LOSS}%"

              if [ "''${LOSS}" -eq 100 ]; then
                CLASS="down"
              elif [ "''${LOSS}" -gt 20 ]; then
                CLASS="critical"
              elif [ "''${LOSS}" -gt 0 ] || (( $(echo "''${AVG_LATENCY} > 150" | bc -l) )); then
                CLASS="poor"
              elif (( $(echo "''${AVG_LATENCY} > 60" | bc -l) )); then
                CLASS="average"
              else
                CLASS="good"
              fi

              printf '{"text": "%s", "tooltip": "Latency: %sms\\nLoss: %s%%", "class": "%s"}\n' "''${TEXT}" "''${AVG_LATENCY}" "''${LOSS}" "''${CLASS}"
            fi
            '';
            })

            # Minecraft Waybar script
            (pkgs.writeShellApplication {
            name = "waybar-mc";
            runtimeInputs = [ pkgs.jq pkgs.mcstatus ];
            text = ''
            DATA=$(mcstatus localhost json 2>/dev/null || true)
            IS_ONLINE=$(echo "$DATA" | jq -r '.online')

            if [ "$IS_ONLINE" = "true" ]; then
              ONLINE=$(echo "$DATA" | jq -r '.status.players.online')
              MAX=$(echo "$DATA" | jq -r '.status.players.max')
              PLAYERS=$(echo "$DATA" | jq -r '.status.players.sample | if . == null then "No players online" else (map(.name) | join(", ")) end')

              printf '{"text": "⛏ %s/%s", "tooltip": "%s", "class": "good"}\n' "$ONLINE" "$MAX" "$PLAYERS"
            else
              printf '{"text": "", "tooltip": "", "class": "critical"}\n'
            fi
            '';
            })

            # Tomestone Check Script
            (pkgs.writers.writePython3Bin "tomestone-check" {
            libraries = [ pkgs.python3Packages.requests ];
            flakeIgnore = [ "E501" ];
            } ''
            import requests
            import json
            import sys
            from datetime import datetime, timezone

            URL = "https://tomestone.gg/character-contents/39794582/tiny-kaoi/activity?page=1"
            HEADERS = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'application/json'
            }

            try:
            response = requests.get(URL, headers=HEADERS, timeout=15)
            response.raise_for_status()
            data = response.json()

            paginator = data.get('activities', {}).get('activities', {}).get('activities', {}).get('paginator', {})
            activities = paginator.get('data', [])

            if not activities:
            print(json.dumps({"text": ""}))
            sys.exit(0)

            latest = activities[0].get('activity', {})
            raw_time = latest.get('endTime', "")
            if not raw_time:
            raw_time = latest.get('startTime', "")

            time_str = "??"
            if raw_time:
            try:
            fight_end_utc = datetime.strptime(raw_time.split('.')[0], "%Y-%m-%d %H:%M:%S").replace(tzinfo=timezone.utc)
            now_utc = datetime.now(timezone.utc)
            if (now_utc - fight_end_utc).total_seconds() > 7200:
            print(json.dumps({"text": ""}))
            sys.exit(0)
            fight_end_local = fight_end_utc.astimezone()
            time_str = fight_end_local.strftime("%H:%M")
            except ValueError:
            pass

            full_name = latest.get('contentLocalizedName', 'Unknown')
            fight_mappings = {
            "AAC Light-heavyweight M1 (Savage)": "M1S",
            "AAC Light-heavyweight M2 (Savage)": "M2S",
            "AAC Light-heavyweight M3 (Savage)": "M3S",
            "AAC Light-heavyweight M4 (Savage)": "M4S",
            "AAC Heavyweight M3 (Savage)": "M11S",
            "AAC Heavyweight M4 (Savage)": "M12S",
            "The Omega Protocol (Ultimate)": "TOP",
            "Futures Rewritten (Ultimate)": "FRU",
            "Dragonsong's Reprise (Ultimate)": "DSR",
            "The Epic of Alexander (Ultimate)": "TEA",
            "The Weapon's Refrain (Ultimate)": "UWU",
            "The Unending Coil of Bahamut (Ultimate)": "UCOB"
            }

            if full_name in fight_mappings:
            display_name = fight_mappings[full_name]
            elif "(Unreal)" in full_name:
            display_name = "Unreal"
            else:
            display_name = full_name.replace("(Savage)", "(S)").replace("(Ultimate)", "(U)")

            kills = latest.get('killsCount', 0)
            is_kill = kills > 0
            if is_kill:
            status_text = "CLEARED"
            metric = latest.get('killDuration', 'N/A')
            css_class = "cleared"
            icon = ""
            else:
            status_text = "WIPE"
            metric = latest.get('bestPercent', 'N/A')
            css_class = "wipe"
            icon = ""

            output = {
            "text": f"{icon} {display_name} {metric} [{time_str}]",
            "tooltip": f"<b>{full_name}</b>\nStatus: {status_text}\nResult: {metric}\nEnded: {raw_time} (UTC)",
            "class": css_class
            }
            print(json.dumps(output))

            except Exception as e:
            print(json.dumps({"text": "Tomestone Err", "tooltip": str(e), "class": "error"}))
            '')

            # Streamtrack Script
            (pkgs.writeShellApplication {
            name = "waybar-streamtrack";
            runtimeInputs = [ pkgs.jq pkgs.yt-dlp ];
            text = ''
            CONFIG_FILE="$HOME/.config/streamtrack/config.json"
            if [ ! -f "$CONFIG_FILE" ]; then
              echo '{"text": "No Config", "class": "error"}'
              exit 0
            fi

            HIGHEST_PRIO=-1
            HIGHEST_NAME=""
            ONLINE_COUNT=0
            TOOLTIP_LIST=""

            while read -r row; do
              CHANNEL=$(echo "$row" | jq -r '.channel')
              NICKNAME=$(echo "$row" | jq -r '.nickname')
              PLATFORM=$(echo "$row" | jq -r '.platform')
              PRIO=$(echo "$row" | jq -r '.priority // 0') 

              URL=""
              if [ "$PLATFORM" == "twitch" ]; then
                URL="https://www.twitch.tv/$CHANNEL"
              elif [ "$PLATFORM" == "youtube" ]; then
                URL="https://www.youtube.com/$CHANNEL/live"
              fi

              IS_LIVE=$(yt-dlp --print is_live --flat-playlist --skip-download "$URL" 2>/dev/null || true)

              if [ "$IS_LIVE" == "True" ]; then
                ONLINE_COUNT=$((ONLINE_COUNT + 1))
                TOOLTIP_LIST="$TOOLTIP_LIST $NICKNAME,"

                if [ "$PRIO" -gt "$HIGHEST_PRIO" ]; then
                  HIGHEST_PRIO=$PRIO
                  HIGHEST_NAME=$NICKNAME
                fi
              fi
            done < <(jq -c '.[]' "$CONFIG_FILE")

            if [ "$ONLINE_COUNT" -eq 0 ]; then
              echo '{"text": "", "class": "offline", "tooltip": "No streams online"}'
            else
              EXTRA_COUNT=$((ONLINE_COUNT - 1))
              if [ "$EXTRA_COUNT" -gt 0 ]; then
                TEXT_OUTPUT="󰑈 $HIGHEST_NAME +$EXTRA_COUNT"
              else
                TEXT_OUTPUT="󰑈 $HIGHEST_NAME"
              fi
              CLEAN_TOOLTIP=''${TOOLTIP_LIST%,}
              echo "{\"text\": \"$TEXT_OUTPUT\", \"tooltip\": \"Live: $CLEAN_TOOLTIP\", \"class\": \"online\"}"
            fi
            '';
            })

            # Work Countdown Script
            (pkgs.writeShellApplication {
            name = "waybar-work-countdown";
            runtimeInputs = [ pkgs.coreutils pkgs.bc ];
            text = ''
            NOW=$(date +%s)
            DOW=$(date +%u)
            HOUR=$(date +%H)

            if [ "$DOW" -le 5 ] && [ "$HOUR" -ge 8 ] && [ "$HOUR" -lt 16 ]; then
              TARGET=$(date -d "16:00" +%s)
              DIFF=$((TARGET - NOW))
              PREFIX="󱎫 End: "
              CLASS="at-work"
            else
              if [ "$DOW" -eq 5 ] && [ "$HOUR" -ge 16 ]; then
                TARGET=$(date -d "next Monday 08:00" +%s)
              elif [ "$DOW" -ge 6 ]; then
                TARGET=$(date -d "next Monday 08:00" +%s)
              else
                if [ "$HOUR" -lt 8 ]; then
                  TARGET=$(date -d "08:00" +%s)
                else
                  TARGET=$(date -d "tomorrow 08:00" +%s)
                fi
              fi
              DIFF=$((TARGET - NOW))
              PREFIX="󱎫 Start: "
              CLASS="off-work"
            fi

            HOURS=$((DIFF / 3600))
            MINUTES=$(((DIFF % 3600) / 60))

            printf '{"text": "%s%dh %dm", "class": "%s"}\n' "$PREFIX" "$HOURS" "$MINUTES" "$CLASS"
            '';
      })
    ];
  };
};
