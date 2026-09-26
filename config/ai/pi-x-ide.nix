{ pkgs, ... }: {
  # pi-x-ide (nvim-Seite): beobachtet Cursor/Selektion (debounced) und
  # verbindet sich ueber den Sidecar (WebSocket) mit pi's pi-x-ide-Erweiterung.
  # Live-Widget in pi: ⧉ flake.nix#L10-L18. Attach: Leertaste a a.
  # Das Sidecar-Binary laed das Plugin beim ersten Start selbst
  # (Node-Fallback vorhanden) — bewusst KEIN Build-Hook in Nix.
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "pi-x-ide";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "balaenis";
        repo = "pi-x-ide";
        rev = "e71423cbebb736702360d2eeb14e3432b5017e62";
        hash = "sha256-Tc9y6vgNVwGoDFwiQ++aRNK5I1iFs2CpGgbXywBS3MQ=";
      };
      sourceRoot = "source/ide-plugins/nvim";
    })
  ];

  extraConfigLua = ''
    require("pi_x_ide").setup({ keymap = "<leader>aa" })

    -- Cursor-/Selektions-Status fuer pi's Statuszeile (Ergaenzung zum
    -- pi-x-ide-Widget, das nur Selektionen zeigt): schreibt debounced
    -- ⧉ <datei>:<zeile> bzw. ⧉ <datei>#Lx-Ly in eine Statusdatei, die die
    -- user-level Erweiterung pi-cursor-status.ts an pi meldet.
    do
      local status_file = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/pi-cursor-status.txt"
      local pending = false

      local function write_status()
        local buf = vim.api.nvim_get_current_buf()
        if vim.bo[buf].buftype ~= "" then return end -- pi-Split: Status einfrieren
        local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
        if name == "" then return end
        local b = vim.fn.mode():byte()
        local is_vis = (b == 118 or b == 86 or b == 22)
        local text
        if is_vis then
          local sl = vim.fn.getpos("v")[2]
          local el = vim.fn.getpos(".")[2]
          if sl > el then sl, el = el, sl end
          text = "⧉ " .. name .. "#L" .. sl .. "-L" .. el
        else
          text = "⧉ " .. name .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
        end
        local f = io.open(status_file, "w")
        if f then f:write(text) f:close() end
      end

      local function schedule_status()
        if pending then return end
        pending = true
        vim.defer_fn(function()
          pending = false
          pcall(write_status)
        end, 200)
      end

      local aug = vim.api.nvim_create_augroup("PiCursorStatus", { clear = true })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged", "BufEnter", "WinEnter" }, {
        group = aug,
        callback = schedule_status,
      })
      schedule_status()
    end
  '';
}
