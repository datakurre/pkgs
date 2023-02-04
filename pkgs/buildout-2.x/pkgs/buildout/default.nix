{ lib, buildPythonPackage, fetchPypi, pip, wheel }:

buildPythonPackage rec {
  pname = "zc.buildout";
  version = "2.13.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Q6sVaHFc6DmaPZmvu3araOsoDhv7xk8a0ZR61LIQxhU=";
  };

  propagatedBuildInputs = [ pip wheel ];

  patches = [ ./nix.patch ];

  meta = with lib; {
    homepage = "http://www.buildout.org";
    description = "A software build and configuration system";
    license = licenses.zpl21;
    maintainers = [ maintainers.goibhniu ];
  };
}
