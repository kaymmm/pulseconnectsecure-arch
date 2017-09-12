pkgname=pulseconnect
pkgver="5.2R8"
pkgrel=1
pkgdesc="Pulse Connect Secure VPN client"
arch=("i686" "x86_64")
url="https://www.library.ucdavis.edu/service/connect-from-off-campus/vpn-questions-known-issues/"
license=("unknown")
depends=("glibc" "zlib" "nss" "glib-networking" "xulrunner" "libproxy" "libxmu" )
makedepends=()
options=("emptydirs")
source=("https://www.library.ucdavis.edu/wp-content/uploads/vpn-clients/pulse-${pkgver}.i386.rpm"
"ConfigurePulse.patch"
"PulseClient.patch")
md5sums=("8a0407e4c2f266a214471bc1c8b5edec"
"cf293fb001d8dfbb41ba30c5b33edfd3"
"2ba22678d7d5afe9e35e269dc836eef1")
install=pulse.install

prepare() {
  patch -p0 "${srcdir}/usr/local/pulse/ConfigurePulse.sh" < "${srcdir}/ConfigurePulse.patch"
  patch -p0 "${srcdir}/usr/local/pulse/PulseClient.sh" < "${srcdir}/PulseClient.patch"
}

package() {
  cp -r "${srcdir}/usr/local/" "${pkgdir}/opt/"
}
