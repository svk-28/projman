Name:           projman
Version:        0.3.8
Release:        alt1
Summary:        Tcl/Tk Project Manager
License:        GPL
Group:          Development/Tcl
Url:            http://conero.lrn.ru
BuildArch:      noarch
Source:         %name-%version-%release.tar.gz
Requires:        bwidget, ctags, tcl-img

%description
This programm is Integrated Development Environment for Tcl/Tk language programming. Include - project manager, text and source editor with syntax highlightning, archive (tar.gz) and PRM builder and more.

%description -l ru_RU.KOI8-R
Интегрированная среда для программирования на Tcl/Tk. Включает в себя - менеджер проектов, полнофункциональный редактор, систему навигации по файлам и структуре файлов и многое другое.

%prep
%setup -n %name

%build

%install
mkdir -p $RPM_BUILD_ROOT{%_bindir,%_datadir/%name/img,%_datadir/%name/msgs,%_datadir/%name/highlight}

install -p -m755 projman.tcl $RPM_BUILD_ROOT%_bindir/%name
install -p -m644 *.tcl $RPM_BUILD_ROOT%_datadir/%name/
install -p -m644 highlight/*.tcl $RPM_BUILD_ROOT%_datadir/%name/highlight/
install -p -m644 *.conf $RPM_BUILD_ROOT%_datadir/%name/
install -p -m644 img/*.* $RPM_BUILD_ROOT%_datadir/%name/img/
install -p -m644 msgs/*.* $RPM_BUILD_ROOT%_datadir/%name/msgs/

# Menu support
mkdir -p $RPM_BUILD_ROOT/usr/lib/menu

cat > $RPM_BUILD_ROOT/usr/lib/menu/%name << EOF
?package(%name): needs=x11 icon="projman.png" section="Applications/Development/Development environments"  title=ProjMan longtitle="Tcl/Tk Project Manager" command=projman
EOF
#mdk icons
install -d $RPM_BUILD_ROOT{%_iconsdir,%_liconsdir,%_miconsdir}
install -p -m644 img/icons/%name.png $RPM_BUILD_ROOT%_iconsdir/
install -p -m644 img/icons/large/%name.png $RPM_BUILD_ROOT%_liconsdir/
install -p -m644 img/icons/mini/%name.png $RPM_BUILD_ROOT%_miconsdir/

%post
%update_menus

%postun
%clean_menus

%files
%doc INSTALL CHANGELOG TODO COPYING README THANKS
%doc hlp/ru/*
%_bindir/%name
%_datadir/%name
%_libdir/menu/%name
%_iconsdir/%name.png
%_liconsdir/%name.png
%_miconsdir/%name.png


%changelog
* Wed Feb 13 2008 Sergey Kalinin <banzaj@altlinux.ru> 0.3.8-alt1
- Added text encoding support from koi8-r,cpp1251,cp866 to UTF-8

* Tue Feb 20 2007 Sergey Kalinin <banzaj@altlinux.ru> 0.3.7-alt4
- Fixed setiings dialog
- Fixed saved  settings parameter

* Wed Oct 18 2006 Sergey Kalinin <banzaj@altlinux.ru> 0.3.7-alt3
- Remove SuperText widget now use native TEXT




