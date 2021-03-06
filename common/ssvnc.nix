{ stdenv
, adoptopenjdk-openj9-bin-8
, fetchurl
, fontDirectories
, imake
, libjpeg
, libXaw
, libXmu
, libXpm
, makeWrapper
, openssh
, openssl
, perl
, perl530Packages
, samba     # smbclient
, stunnel
, tcl
, tk        # wish
, xauth
, xlibsWrapper
, zlib
}:

let
  pname = "ssvnc";
  version = "1.0.29";
in
stdenv.mkDerivation {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://downloads.sf.net/sourceforge/${pname}/${pname}-${version}.src.tar.gz";
    sha256 = "13b1gmaprznkd171vgiwgxy62m11wkmk58lkjryb0s5aivmk5pvl";
  };

  patches = [ ./ssvnc-openssl1.1.patch ];

  postPatch = ''
    substituteInPlace scripts/util/ss_vncviewer --replace /usr/bin/perl "${perl}/bin/perl" 
  '';

  # for the builder script
  inherit fontDirectories;

  hardeningDisable = [ "format" ];

  buildInputs = [
    adoptopenjdk-openj9-bin-8 # jar and javac
    imake
    libjpeg
    libXaw
    libXmu
    libXpm
    makeWrapper
    openssh
    openssl
    perl
    stunnel
    tcl
    tk
    xauth
    zlib
  ];

  propagatedBuildInputs = [ xlibsWrapper ];

  runtimeDependencies = [ perl530Packages.IOSocketInet6 ];

  makeFlags = [ "PREFIX=$(out)" ];
  postFixup = ''
    #sed -i -e '1c#!${tk}/bin/wish' "$out/bin/sc_remote"
    for cmd in $out/bin/*; do
      wrapProgram "$cmd" --prefix PATH : "${stdenv.lib.makeBinPath [
    adoptopenjdk-openj9-bin-8
    openssh
    samba
    stunnel
    tk
  ]}"
    done
  '';

  meta = {
    license = stdenv.lib.licenses.gpl2;
    homepage = http://www.karlrunge.com/x11vnc/ssvnc.html;
    description = "SSL/SSH VNC viewer";

    longDescription = ''
      The Enhanced TightVNC Viewer, SSVNC, adds encryption security to VNC connections.
    '';

    maintainers = [ stdenv.lib.maintainers.michojel ];
    platforms = stdenv.lib.platforms.unix;
  };
}
