# grep-mcp - MCP server for grep.app code search
# https://github.com/galprz/grep-mcp
{
  lib,
  python3Packages,
  fetchPypi,
}:

python3Packages.buildPythonApplication rec {
  pname = "grep-mcp";
  version = "1.0.3";
  pyproject = true;

  src = fetchPypi {
    pname = "grep_mcp";
    inherit version;
    hash = "sha256-5bCOQBA+7Y38JzqZ0VQuTIXfu52tQs6ziV7Ffe5wljU=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    aiohttp
    mcp
    starlette
    uvicorn
  ];

  # No tests in the package
  doCheck = false;

  meta = {
    description = "MCP server for searching GitHub code via grep.app";
    homepage = "https://github.com/galprz/grep-mcp";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "grep-mcp";
  };
}
