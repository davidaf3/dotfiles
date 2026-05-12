{
  rustPlatform,
  pkg-config,
  openssl,
  ...
}:

rustPlatform.buildRustPackage {
  pname = "rust-scripts";
  version = "0.1.0";
  src = ./.;
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];
}
