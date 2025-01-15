{system, ...}: {
  imports =
    [
      ./matrix.nix
      ./signal.nix
      ./discord.nix
      ./whatsapp.nix
      ./telegram.nix
      ./xmpp.nix
      ./irc.nix
      ./voip.nix
    ]
    ++ (
      if system == "x86_64-linux"
      then [./slack.nix]
      else []
    );
}
