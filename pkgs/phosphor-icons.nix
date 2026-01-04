# Phosphor Icons - TTF fonts from the web package
# https://github.com/phosphor-icons/web
{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "phosphor-icons";
  version = "2.1.1";

  src = fetchzip {
    url = "https://github.com/phosphor-icons/web/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-Ul0UtnsrJ4pUY+rozU7W6DIpIq7DstQN69sOql4x6Yc=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 src/regular/Phosphor.ttf $out/share/fonts/truetype/Phosphor.ttf
    install -Dm644 src/bold/Phosphor-Bold.ttf $out/share/fonts/truetype/Phosphor-Bold.ttf
    install -Dm644 src/light/Phosphor-Light.ttf $out/share/fonts/truetype/Phosphor-Light.ttf
    install -Dm644 src/thin/Phosphor-Thin.ttf $out/share/fonts/truetype/Phosphor-Thin.ttf
    install -Dm644 src/fill/Phosphor-Fill.ttf $out/share/fonts/truetype/Phosphor-Fill.ttf
    install -Dm644 src/duotone/Phosphor-Duotone.ttf $out/share/fonts/truetype/Phosphor-Duotone.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Phosphor icon fonts (TTF)";
    homepage = "https://phosphoricons.com";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
