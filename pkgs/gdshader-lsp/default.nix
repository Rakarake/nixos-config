{
  rustPlatform,
  pkg-config,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage {
  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "gdshader-lsp";
    hash = "sha256-KMP7TmamtbycF/nKctjYozMJwVr9zdp4A8AWriswo2g=";
  };
  nativeBuildInputs = [
  ];
  buildInputs = [
  ];
}
