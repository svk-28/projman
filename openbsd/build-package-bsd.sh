#!/bin/bash
# create-openbsd-pkg.sh

PKG_NAME="projman"
WORK_DIR=projman_openbsd
VERSION=$(grep Version ../projman.tcl | grep -oE '\b[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}\b')
RELEASE=$(grep "# Release" ../projman.tcl | grep -oE '[0-9A-Za-z]+$')
BUILD_DATE=$(date +%d%m%Y%H%M%S)
TXT="# Build: ${BUILD_DATE}"
echo "$VERSION, $RELEASE, $BUILD_DATE"

PKG_VERSION="${VERSION}${RELEASE}"
PKG_FULLNAME="${PKG_NAME}-${PKG_VERSION}"

mkdir -p ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin
mkdir -p ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman
mkdir -p ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/man/man1

cp -r ../lib ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman/
cp -r ../theme ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman/
cp ../projman.tcl ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/projman
cp ../changelog-gen.tcl ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/changeloggen
cp ../tkregexp.tcl ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/tkregexp
cp ../LICENSE ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman/
cp ../README.md ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman/
cp ../CHANGELOG ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman/
cp ../projman.desktop ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman/
cp ../projman.png ${WORK_DIR}/${PKG_FULLNAME}/usr/local/share/projman/

sed -i "/# Build:.*/c$TXT"  ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/projman

# ./changelog-gen.tcl  --project-name projman --project-version ${VERSION} --project-release ${RELEASE} --out-file debian/changelog --deb --last

sed -i "s+^set\ dir(lib)+set\ dir(lib)\ /usr/local/share/projman/lib ;#+g"  ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/projman
   
sed -i "s+\[pwd\]+/usr/local/share/projman+g"  ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/projman

# cat > ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/projman << 'EOF'
# #!/bin/sh
# exec /usr/local/bin/wish8.6 "/usr/local/share/projman/projman.tcl" "$@"
# EOF
# chmod +x ${WORK_DIR}/${PKG_FULLNAME}/usr/local/bin/projman

cat > ${WORK_DIR}/${PKG_FULLNAME}/+CONTENTS << EOF
@name ${PKG_NAME}-${PKG_VERSION}
@version ${PKG_VERSION}
@depend lang/tk:tk-*:tcl-*
@depend devel/tcllib:tcllib-*:tcl-*
@depend devel/tklib:tklib-*:tcl-*
@comment Editor for Tcl/Tk and other languages.
@arch amd64
@ignore
@cwd /usr/local
EOF

(cd ${WORK_DIR}/${PKG_FULLNAME}/usr/local && find . -type f | sed 's/^\.\///') | while read file; do
    echo "$file" >> ${WORK_DIR}/${PKG_FULLNAME}/+CONTENTS
done

cat >> ${WORK_DIR}/${PKG_FULLNAME}/+CONTENTS << 'EOF'
@exec mkdir -p /var/log/projman 2>/dev/null || true
@exec echo "Package ${PKG_NAME} installed successfully"
@unexec rm -rf /var/log/projman 2>/dev/null || true
EOF

echo "ProjMan is a code editor writen in TCL/Tk" > ${WORK_DIR}/${PKG_FULLNAME}/+COMMENT

cat > ${WORK_DIR}/${PKG_FULLNAME}/+DESC << 'EOF'
ProjMan (also known as "Tcl/Tk Project Manager") is a feature-rich editor
for programming in Tcl/Tk and other languages.

It includes a source editor with syntax highlighting and
code navigation, a context-sensitive help system, Git support, a
pseudo-terminal, image viewer and much more.

Supported languages for highlighting and navigation:
Tcl/Tk, GO, Perl, Python, Ruby, Shell (BASH), Markdown, YAML (Ansible), Lua.
EOF

(cd ${WORK_DIR}/${PKG_FULLNAME}/ && pwd && ls -1 && tar -czf ../../../../${PKG_FULLNAME}.tgz .)

echo "Package created: ${PKG_FULLNAME}.tgz"

rm -rf ${WORK_DIR}
