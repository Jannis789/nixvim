{ pkgs, ... }:

{
  extraPlugins = [{
    plugin = pkgs.vimUtils.buildVimPlugin {
      pname = "agentic-nvim";
      version = "main";
      src = pkgs.runCommandLocal "agentic-nvim-source" {} ''
        cp -r ${pkgs.fetchFromGitHub {
          owner = "carlos-algms";
          repo = "agentic.nvim";
          rev = "a19fee663aa8be5f46f0af6fc0b46427b0e75cf2";
          hash = "sha256-ZT1ME4E8jwC6DPLVpEgCudL8go91q7PkfJn5ylajmYA=";
        }} $out
        chmod -R +w $out
        find $out -name '*.test.lua' -delete
      '';
    };
  }];

  extraConfigLua = ''
    require("agentic").setup({
      provider = "hermes-acp",
      acp_providers = {
        ["hermes-acp"] = {
          name = "Hermes Agent",
          command = "hermes",
          args = { "acp" },
        },
      },
      windows = {
        position = "right",
        width = "40%",
      },
    })

  '';

  keymaps = [
    {
      key = "<leader>d";
      action.__raw = ''function() require("agentic").toggle() end'';
      options.desc = "Toggle Agentic Chat";
      mode = ["n" "v"];
    }
  ];
}
