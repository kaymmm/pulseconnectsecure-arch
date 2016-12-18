pkgname=pulseconnect
pkgver="8.2R5"
pkgrel=1
pkgdesc="Pulse Connect Secure VPN client"
arch=("i686" "x86_64")
url="https://kb.pulsesecure.net/articles/Pulse_Secure_Article/KB40126"
license=("unknown")
depends=("glibc" "webkitgtk" "zlib" "nss" "glib-networking" "xulrunner" "libproxy" "libxmu" "lib32-libsoup" "lib32-gtk3")
makedepends=()
options=("emptydirs")
source=("https://www.library.ucdavis.edu/ul/services/connect/clients/pulse-${pkgver}.i386.rpm"
"ConfigurePulse.patch"
"PulseClient.patch")
md5sums=("cb5be8f78674cd413f6abee6efc7f909"
"1f5d97fdd18947c5cac7f8dc9c4624c7"
"290f7fc5b020827381754c61515fe549")
install=pulse.install

prepare() {
  patch -p0 "${srcdir}/usr/local/pulse/ConfigurePulse.sh" < "${srcdir}/ConfigurePulse.patch"
  patch -p0 "${srcdir}/usr/local/pulse/PulseClient.sh" < "${srcdir}/PulseClient.patch"
}

package() {
  cp -r "${srcdir}/usr/local/" "${pkgdir}/opt/"
}
