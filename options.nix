{
  lib,
  ...
}:

{
  options.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "Matugen colors";
  };
}
