{ lib, buildPythonPackage, fetchPypi, pip, wheel }:

buildPythonPackage rec {
  pname = "zc.buildout";
  version = "3.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-DIxurjbejtgifVKNxM/dsFRZeDSMnu8IkHOUhv6VSys=";
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
