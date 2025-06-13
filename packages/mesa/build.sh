TERMUX_PKG_HOMEPAGE=https://www.mesa3d.org
TERMUX_PKG_DESCRIPTION="An open-source implementation of the OpenGL specification"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_LICENSE_FILE="docs/license.rst"
TERMUX_PKG_MAINTAINER="@termux"
<<<<<<< HEAD
TERMUX_PKG_VERSION="25.1.1"
TERMUX_PKG_REVISION=2
_LLVM_MAJOR_VERSION=$(. $TERMUX_SCRIPTDIR/packages/libllvm/build.sh; echo "${LLVM_MAJOR_VERSION}")
_LLVM_MAJOR_VERSION_NEXT=$((_LLVM_MAJOR_VERSION + 1))
TERMUX_PKG_SRCURL=https://archive.mesa3d.org/mesa-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=cf942a18b7b9e9b88524dcbf0b31fed3cde18e6d52b3375b0ab6587a14415bce
=======
TERMUX_PKG_VERSION="24.3.4"
TERMUX_PKG_REVISION=1
_LLVM_MAJOR_VERSION=$(. $TERMUX_SCRIPTDIR/packages/libllvm/build.sh; echo $LLVM_MAJOR_VERSION)
_LLVM_MAJOR_VERSION_NEXT=$((_LLVM_MAJOR_VERSION + 1))
TERMUX_PKG_SRCURL=https://archive.mesa3d.org/mesa-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=e641ae27191d387599219694560d221b7feaa91c900bcec46bf444218ed66025
>>>>>>> 59184dbe29 (test build)
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libandroid-shmem, libc++, libdrm, libglvnd, libllvm (<< ${_LLVM_MAJOR_VERSION_NEXT}), libwayland, libx11, libxext, libxfixes, libxshmfence, libxxf86vm, ncurses, vulkan-loader, zlib, zstd"
TERMUX_PKG_SUGGESTS="mesa-dev"
TERMUX_PKG_BUILD_DEPENDS="libwayland-protocols, libxrandr, llvm, llvm-tools, mlir, xorgproto"
TERMUX_PKG_BREAKS="osmesa, osmesa-demos"
TERMUX_PKG_CONFLICTS="libmesa, ndk-sysroot (<= 25b), osmesa"
TERMUX_PKG_REPLACES="libmesa, osmesa"

# FIXME: Set `shared-llvm` to disabled if possible
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--cmake-prefix-path $TERMUX_PREFIX
-Dcpp_rtti=false
-Dgbm=enabled
-Dopengl=true
-Degl=enabled
-Degl-native-platform=x11
-Dgles1=disabled
-Dgles2=enabled
-Dglx=dri
-Dllvm=enabled
-Dshared-llvm=enabled
-Dplatforms=x11,wayland
<<<<<<< HEAD
=======
-Dosmesa=true
>>>>>>> 59184dbe29 (test build)
-Dglvnd=enabled
-Dxmlconfig=disabled
"

termux_pkg_auto_update() {
	read -r latest < <(curl -fsSL "https://archive.mesa3d.org/" | sed -rn 's/.*mesa-([0-9]+(\.[0-9]+)*).*/\1/p' | sort -Vr);
	termux_pkg_upgrade_version "${latest}"
}

termux_step_post_get_source() {
	# Do not use meson wrap projects
	rm -rf subprojects
}

termux_step_pre_configure() {
	termux_setup_cmake

	CPPFLAGS+=" -D__USE_GNU"
<<<<<<< HEAD
=======
	CPPFLAGS+=" -D__ANDROID_API__=$(getprop ro.build.version.sdk)"

>>>>>>> 59184dbe29 (test build)
	LDFLAGS+=" -landroid-shmem"

	_WRAPPER_BIN=$TERMUX_PKG_BUILDDIR/_wrapper/bin
	mkdir -p $_WRAPPER_BIN
	if [ "$TERMUX_ON_DEVICE_BUILD" = "false" ]; then
		sed 's|@CMAKE@|'"$(command -v cmake)"'|g' \
			$TERMUX_PKG_BUILDER_DIR/cmake-wrapper.in \
			> $_WRAPPER_BIN/cmake
		chmod 0700 $_WRAPPER_BIN/cmake
		termux_setup_wayland_cross_pkg_config_wrapper
		export LLVM_CONFIG="$TERMUX_PREFIX/bin/llvm-config"
	fi
	export PATH="$_WRAPPER_BIN:$PATH"

<<<<<<< HEAD
	local _vk_drivers="swrast"
	local _opengl_drivers="llvmpipe,softpipe,virgl,zink"
	if [ $TERMUX_ARCH = "arm" ] || [ $TERMUX_ARCH = "aarch64" ]; then
		_vk_drivers+=",freedreno"
		_opengl_drivers+=",freedreno"
=======

	if [ $TERMUX_ARCH = "arm" ] || [ $TERMUX_ARCH = "aarch64" ]; then
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dgallium-drivers=swrast,virgl,zink,freedreno"
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dvulkan-drivers=swrast,freedreno"
>>>>>>> 59184dbe29 (test build)
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dfreedreno-kmds=msm,kgsl"
	elif [ $TERMUX_ARCH = "i686" ] || [ $TERMUX_ARCH = "x86_64" ]; then
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dgallium-drivers=swrast,virgl,zink"
		TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dvulkan-drivers=swrast"
	else
		termux_error_exit "Invalid arch: $TERMUX_ARCH"
	fi
<<<<<<< HEAD
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dvulkan-drivers=$_vk_drivers"
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" -Dgallium-drivers=$_opengl_drivers"
=======
>>>>>>> 59184dbe29 (test build)
}

termux_step_post_configure() {
	rm -f $_WRAPPER_BIN/cmake
}

termux_step_post_make_install() {
	# Avoid hard links
	local f1
	for f1 in $TERMUX_PREFIX/lib/dri/*; do
		if [ ! -f "${f1}" ]; then
			continue
		fi
		local f2
		for f2 in $TERMUX_PREFIX/lib/dri/*; do
			if [ -f "${f2}" ] && [ "${f1}" != "${f2}" ]; then
				local s1=$(stat -c "%i" "${f1}")
				local s2=$(stat -c "%i" "${f2}")
				if [ "${s1}" = "${s2}" ]; then
					ln -sfr "${f1}" "${f2}"
				fi
			fi
		done
	done

	# Create symlinks
	ln -sf libEGL_mesa.so ${TERMUX_PREFIX}/lib/libEGL_mesa.so.0
	ln -sf libGLX_mesa.so ${TERMUX_PREFIX}/lib/libGLX_mesa.so.0
}
