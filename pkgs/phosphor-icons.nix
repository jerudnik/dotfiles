{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "phosphor-icons";
  version = "2.0.8";

  src = fetchzip {
    url = "https://github.com/phosphor-icons/core/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-1ipkbbj2rmb952m9j39dg6jcb7vjarjl0xc6yiqcr0wck761f9bb";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 assets/fonts/*.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = with lib; {
    description = "Phosphor icon fonts (TTF)";
    homepage = "https://phosphoricons.com";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
