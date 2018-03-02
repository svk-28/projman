Name:           projman
Version:        0.4.5
Release:        rh1
Summary:        Tcl/Tk Project Manager
License:        GPL
Group:          Development/Tcl
Url:            https://bitbucket.org/svk28/projman
BuildArch:      noarch
Source:         %name-%version-%release.tar.gz
Requires:       tcl, tk, bwidget, tcl-img

%description
This programm is Integrated Development Environment for Tcl/Tk language programming. Include - project manager, text and source editor with syntax highlightning, archive (tar.gz) and PRM builder and more.

%description -l ru_RU.UTF8
Интегрированная среда для программирования на Tcl/Tk. Включает в себя - менеджер проектов, полнофункциональный редактор, систему навигации по файлам и структуре файлов и многое другое.

%prep
%setup -n %name

%build

%install
mkdir -p $RPM_BUILD_ROOT{%_bindir,%_datadir/%name/{img,msgs,/lib/highlight}}

install -p -m755 projman.tcl $RPM_BUILD_ROOT%_bindir/%name
install -p -m644 *.tcl $RPM_BUILD_ROOT%_datadir/%name/
install -p -m644 lib/highlight/*.tcl $RPM_BUILD_ROOT%_datadir/%name/highlight/
install -p -m644 *.conf $RPM_BUILD_ROOT%_datadir/%name/
install -p -m644 img/*.* $RPM_BUILD_ROOT%_datadir/%name/img/
install -p -m644 msgs/*.* $RPM_BUILD_ROOT%_datadir/%name/msgs/

# Menu support
#mkdir -p $RPM_BUILD_ROOT/usr/lib/menu
#cat > $RPM_BUILD_ROOT%_libdir/menu/%name << EOF
#?package(%name): needs=x11 icon="projman.png" section="Applications/Development/Development environments"  title=ProjMan longtitle="Tcl/Tk Project Manager" command=projman
#EOF
#mdk icons
#install -d $RPM_BUILD_ROOT{%_iconsdir,%_liconsdir,%_miconsdir}
#install -p -m644 img/icons/%name.png $RPM_BUILD_ROOT%_iconsdir/
#install -p -m644 img/icons/large/%name.png $RPM_BUILD_ROOT%_liconsdir/
#install -p -m644 img/icons/mini/%name.png $RPM_BUILD_ROOT%_miconsdir/

%post
%update_menus

%postun
%clean_menus

%files
%doc INSTALL CHANGELOG TODO COPYING README THANKS
%doc hlp/ru/*
%_bindir/%name
%_datadir/%name
#%_libdir/menu/%name
#%_iconsdir/%name.png
#%_liconsdir/%name.png
#%_miconsdir/%name.png


%changelog
* Fri Feb 16 2018 Sergey Kalinin <banzaj@altlinux.ru> 0.4.5
- Added saving main window geometry into projman.conf file when close programm
- Fixed AutoComplite precedure for TCL/TK-projects
- Added colored icon for main window
- Fixed "Close all" procedure if opened files from projects and file browser
- Fixed parsing some procedure name like ::proc::name or proc_na::me(aa) and parameters {{} {} {}}
- Added opening last active project when project run
- Fixed Windows OS running without installation
- Added gray theme
- Fixed work with file from directory (FileBrowser function).
- Auto indent added for () [] braces
- File Browser added. Now we will edited any file without project
- Tcl, Perl, PHP highlight comment procedure fixed
- Help file Text.html utf-8 encoding
- Change hotkeys "Control+," "Control+." "Control+/" (commect selected, uncoment selected, select all)
- Add new function Comments/Uncomment selected text
- Added binding mouse button: click on notebook tab highlight opened file name in tree
- Change "Paste from Clipboard" function
- Change popup editor menu (undo, redo, copy, paste, cut functions)
- Change Logo and About dialog
- Russian help files was conerting into utf-8 encode
- Change help file load procedure
- Fixed paste text highlight
- Fixed setting edited flag when paste the text from buffer
- Remove ctags support
- Added gitk (gui for git) support
- Changes color setting dialog into "Setting"
- Actualizing information into "About" dialog 
- Corrected color settings for all widgets
- Change default color scheme
- Remove ctag, change autocomplitt procedure

* Wed Feb 13 2008 Sergey Kalinin <banzaj@altlinux.ru> 0.3.8-alt1
- Added text encoding support from koi8-r,cpp1251,cp866 to UTF-8

* Tue Feb 20 2007 Sergey Kalinin <banzaj@altlinux.ru> 0.3.7-alt4
- Fixed setiings dialog
- Fixed saved  settings parameter

* Wed Oct 18 2006 Sergey Kalinin <banzaj@altlinux.ru> 0.3.7-alt3
- Remove SuperText widget now use native TEXT






