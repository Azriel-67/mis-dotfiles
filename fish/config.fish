if status is-interactive
    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    # Custom fish config
    set -q XDG_CONFIG_HOME && set -l cConf $XDG_CONFIG_HOME/caelestia || set -l cConf $HOME/.config/caelestia
    source $cConf/user-config.fish 2> /dev/null
end

alias wps='~/.local/bin/wps-es'
alias wpp='~/.local/bin/wpp-es'
alias et='~/.local/bin/et-es'

# ==========================================
# HERRAMIENTAS DE RASTREO PSICOMÉTRICO
# ==========================================

# 1. Búsqueda visual en navegador (Brave/Zen)
function buscar_test --description "Abre dorks de pruebas en Brave o Zen"
    set -l browser "brave"
    set -l test_name ""

    for arg in $argv
        if test "$arg" = "--zen"
            set browser "zen-browser"
        else
            set test_name "$arg"
        end
    end

    if test -z "$test_name"
        set_color red; echo "Error: Falta el nombre. Uso: buscar_test CUMANIN-2 [--zen]"; set_color normal
        return 1
    end

    set_color cyan; echo "[Caelestia OS] Buscando en $browser: $test_name..."; set_color normal
    set -l query "(\"$test_name\") (manual OR cuadernillo) (filetype:pdf OR site:udocz.com OR site:scribd.com)"
    set -l encoded_query (string escape --style=url "$query")
    $browser "https://www.google.com/search?q=$encoded_query" &>/dev/null &
end

# 2. Descarga directa de PDFs en Terminal (FZF + Wget)
function obtener_test --description "Descarga PDFs clínicos directamente en CLI"
    set -l test_name $argv
    if test -z "$test_name"
        set_color red; echo "Error: Falta el nombre. Uso: obtener_test WISC-V"; set_color normal
        return 1
    end

    set_color cyan; echo "[Caelestia OS] Rastreador PDF activado para: $test_name..."; set_color normal
    
    # Query simplificado para no saturar ddgr
    set -l query "$test_name manual filetype:pdf"
    set -l seleccion (ddgr -n 15 --json $query 2>/dev/null | jq -r '.[] | "\(.title) ||| \(.url)"' | fzf --prompt="📄 Selecciona el PDF (Enter) > " --border=rounded --height=40%)

    if test -n "$seleccion"
        set -l partes (string split " ||| " "$seleccion")
        set -l url $partes[-1]
        
        set_color yellow; echo "Extrayendo desde: $url"; set_color normal
        wget -c --content-disposition --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$url"
        set_color green; echo "✅ Descarga completada en: "(pwd); set_color normal
    else
        set_color red; echo "Cancelado."; set_color normal
    end
end

# 3. Rastreador Global de Software, Plantillas (Excel) y Kits (ZIP/RAR)
   function obtener_plantilla --description "Busca software globalmente con multi-servidor automático"
    set -l test_name $argv
    if test -z "$test_name"
        set_color red; echo "Error: Falta el nombre. Uso: obtener_plantilla \"WPPSI III\""; set_color normal
        return 1
    end

    set_color cyan; echo "[Caelestia OS] Escaneando la red global para: $test_name..."; set_color normal
    set -l query "\"$test_name\" (excel OR xlsx OR zip OR rar OR software OR plantilla)"
    set -l encoded_query (string escape --style=url "$query")
    
    # Lista de 4 servidores estables de respaldo
    set -l servidores "https://paulgo.io" "https://searx.be" "https://priv.au" "https://search.unlocked.link"
    set -l json_data ""
    
    # Bucle: Prueba cada servidor. Si falla o bloquea, pasa al siguiente.
    for servidor in $servidores
        echo "Conectando a: $servidor..."
        set json_data (curl -s -m 4 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$servidor/search?q=$encoded_query&format=json")
        
        # Verifica si el servidor devolvió resultados JSON válidos
        if echo "$json_data" | jq -e '.results[0]' >/dev/null 2>&1
            set_color green; echo "✅ Servidor activo encontrado."; set_color normal
            break
        end
    end

    # Extrae los resultados al menú interactivo
    set -l seleccion (echo "$json_data" | jq -r '.results[]? | "\(.title) ||| \(.url)"' | fzf --prompt="💻 Selecciona (Enter) > " --border=rounded --height=50%)

    if test -n "$seleccion"
        set -l partes (string split " ||| " "$seleccion")
        set -l url $partes[-1]
        set_color yellow; echo "Enlace: $url"; set_color normal
        
        if string match -q -r -i '\.(xlsx|xls|zip|rar)$' "$url"
            wget -q --show-progress -c --content-disposition --user-agent="Mozilla/5.0" "$url"
            set_color green; echo "✅ Descarga completada en: "(pwd); set_color normal
        else
            if command -v wl-copy &> /dev/null
                echo "$url" | wl-copy
                set_color green; echo "✅ Enlace web copiado al portapapeles. Pégalo en tu navegador."; set_color normal
            else
                echo "Copia este enlace en tu navegador: $url"
            end
        end
    else
        set_color red; echo "Cancelado o sin resultados."; set_color normal
    end
end
