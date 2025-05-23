{ pkgs }:
pkgs.writeShellScriptBin "etyp" ''
touch $1
if ${pkgs.typst}/bin/typst compile $1; then
  # Open generated PDF
  xdg-open $(echo ${"$" + "{1%.*}" + ".pdf"}) &
fi
2>/dev/null 1>/dev/null ${pkgs.typst}/bin/typst watch $1 &
$EDITOR $1
echo "closing background tasks"
kill %1
kill %2
''
