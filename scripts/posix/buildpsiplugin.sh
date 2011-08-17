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

qmake
make

cd "${curdir}"

echo
ls -l ${PLUGIN_DIR}/build/generic/sofgameplugin/*.so
echo

echo "Done."
