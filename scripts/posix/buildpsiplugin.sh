#!/usr/bin/env sh
##
# Скрипт сборки Sofgame plugin под Linux
##

# ТРЕБОВАНИЯ

# Для сборки плагина вам понадобятся следующие пакеты
# git - vcs system / система контроля версий
# gcc - compiler / компилятор
# qt4 тулзы либы и хидеры (наверное "dev" пакеты)

# OPTIONS / НАСТРОЙКИ

# Каталог для сборки
PLUGIN_DIR="_psiplugin"
# Пути к исходникам и заголовочным файлам psi-plus
GIT_REPO_PLUGIN="git://github.com/sofgame-plugin/psiplus-plugin.git"
GIT_REPO_TOOLS="git://github.com/sofgame-plugin/plugin-tools.git"
# Опции для make
MAKEOPT=""


die() { echo; echo " !!!ERROR: $@"; exit 1; }
log() { local opt; [ "$1" = "-n" ] && { opt="-n"; shift; }; echo $opt "*** $@"; }

git_fetch() {
	local remote="$1"
	local target="$2"
	local comment="$3"
	local curd=`pwd`
	if [ -d "${target}/.git" ]
	then
		cd "${target}"
		[ -n "${comment}" ] && log "Update ${comment} .."
		git pull || die "git update failed"
	else
		log "Checkout ${comment} .."
		git clone "${remote}" "$target" || die "git clone failed"
	fi
	cd "${curd}"
}

fetch_tools() {
	local curd=`pwd`
	cd "${PLUGIN_DIR}"
	git_fetch "${GIT_REPO_TOOLS}" plugin-tools "Tools and psi+ headers"
	cd "${curd}"
}

fetch_plugin() {
	local curd=`pwd`
	cd "${PLUGIN_DIR}"
	git_fetch "${GIT_REPO_PLUGIN}" sofgameplugin "Plugin sources"
	cd "${curd}"
}

get_make_opt() {
	case "`uname`" in
	FreeBSD)
		MAKEOPT=${MAKEOPT:--j$((`sysctl -n hw.ncpu`+1))}
		;;
	Darwin)
		MAKEOPT=${MAKEOPT:--j$((`sysctl -n hw.ncpu`+1))}
		;;
	SunOS)
		local CPUS=`/usr/sbin/psrinfo | grep on-line | wc -l | tr -d ' '`
		if test "x$CPUS" = "x" -o $CPUS = 0; then
			CPUS=1
		fi
		MAKEOPT=${MAKEOPT:--j$CPUS}
		;;
	MINGW32*)
		;;
	*)
		MAKEOPT=${MAKEOPT:--j$((`cat /proc/cpuinfo | grep processor | wc -l`+1))}
		;;
	esac
}

if [ ! -d "${PLUGIN_DIR}" ]
then
	mkdir "${PLUGIN_DIR}" || die "can't create work directory ${PLUGIN_DIR}"
fi
if [ -d "${PLUGIN_DIR}"/build ]
then
	rm -rf "${PLUGIN_DIR}"/build || die "can't remove build directory ${PLUGIN_DIR}/build"
fi
mkdir -p "${PLUGIN_DIR}"/build/generic || die "can't create build directory ${PLUGIN_DIR}/build/generic"
log "Created base directory structure"

fetch_tools
fetch_plugin

curdir=`pwd`
cd "${PLUGIN_DIR}"
cp -r plugin-tools/psiplus-headers/* build/
cp -r sofgameplugin build/generic/
cd build/generic/sofgameplugin

if [ "$1" = "develop" ]
then
	log "Checkout to develop .."
	git checkout -b develop origin/develop
	log "Fix version .."
	hash=`git log -n 1 --pretty=format:%h`
	sed -i -E "s/([0-9]+\\.[0-9]+\\.[0-9]+\\.dev)/\\1-${hash}/" plugin_core.h
else
	log "Checkout to master .."
	git checkout master
fi

log "QMake .."
qmake
log "Make .."
get_make_opt
make ${MAKEOPT}

cd "${curdir}"

echo
ls -l ${PLUGIN_DIR}/build/generic/sofgameplugin/*.so
echo

echo "Done."
