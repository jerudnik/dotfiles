# Productivity applications
# Obsidian: Knowledge base and note-taking
# Zotero: Reference management
{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # ============================================================
    # Obsidian - Knowledge management
    # ============================================================
    # Markdown-based note-taking with linking and graph view
    obsidian

    # ============================================================
    # Zotero - Reference management
    # ============================================================
    # Collect, organize, cite, and share research
    zotero
  ];
}
