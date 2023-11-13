; this is a NSI spec file,
; it is autogenerated by the xmake build system.
; do not edit by hand.

; includes
!include "MUI2.nsh"
!include "WordFunc.nsh"
!include "WinMessages.nsh"
!include "FileFunc.nsh"
!include "UAC.nsh"

; the version information
!define VERSION      ${PACKAGE_VERSION}
!define VERSION_FULL ${PACKAGE_VERSION}+${PACKAGE_VERSION_BUILD}

; set the package name
Name "${PACKAGE_NAME} - v${VERSION}"

; set the output file name
OutFile "${PACKAGE_FILENAME}"

; use unicode
Unicode true

; use best compressor
SetCompressor /FINAL /SOLID lzma
SetCompressorDictSize 64
SetDatablockOptimize ON

; set the default installation directory
!if "${PACKAGE_ARCH}" == "x64"
  !define PROGRAMFILES $PROGRAMFILES64
  !define HKLM HKLM64
  !define HKCU HKCU64
!else
  !define PROGRAMFILES $PROGRAMFILES
  !define HKLM HKLM
  !define HKCU HKCU
!endif

; request application privileges for Windows Vista
RequestExecutionLevel user

; set DPI aware
ManifestDPIAware true

; UAC
!macro Init thing
  uac_tryagain:
  !insertmacro UAC_RunElevated
  ${Switch} $0
  ${Case} 0
    ${IfThen} $1 = 1 ${|} Quit ${|} ;we are the outer process, the inner process has done its work, we are done
    ${IfThen} $3 <> 0 ${|} ${Break} ${|} ;we are admin, let the show go on
    ${If} $1 = 3 ;RunAs completed successfully, but with a non-admin user
      MessageBox mb_YesNo|mb_IconExclamation|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, try again" /SD IDNO IDYES uac_tryagain IDNO 0
    ${EndIf}
    ;fall-through and die
  ${Case} 1223
    MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "This ${thing} requires admin privileges, aborting!"
    Quit
  ${Case} 1062
    MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Logon service not running, aborting!"
    Quit
  ${Default}
    MessageBox mb_IconStop|mb_TopMost|mb_SetForeground "Unable to elevate, error $0"
    Quit
  ${EndSwitch}

  ; The UAC plugin changes the error level even in the inner process, reset it.
  ; note fix install exit code 1223 to 0 with slient /S
  SetErrorLevel 0
  SetShellVarContext all
!macroend

; add the install Pages
!insertmacro MUI_PAGE_WELCOME
;!insertmacro MUI_PAGE_LICENSE "..\LICENSE.md"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; add uninstall Pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; add languages
!insertmacro MUI_LANGUAGE "English"

; set product information
VIProductVersion                         "${VERSION}.0"
VIFileVersion                            "${VERSION}.0"
VIAddVersionKey /LANG=0 ProductName      "${PACKAGE_NAME}"
VIAddVersionKey /LANG=0 Comments         "${PACKAGE_DESCRIPTION}"
VIAddVersionKey /LANG=0 CompanyName      "${PACKAGE_COMPANY}"
VIAddVersionKey /LANG=0 LegalCopyright   "${PACKAGE_COPYRIGHT}"
VIAddVersionKey /LANG=0 FileDescription  "${PACKAGE_NAME} Installer - v${VERSION}"
VIAddVersionKey /LANG=0 OriginalFilename "${PACKAGE_FILENAME}"
VIAddVersionKey /LANG=0 FileVersion      "${VERSION_FULL}"
VIAddVersionKey /LANG=0 ProductVersion   "${VERSION_FULL}"

; set registry paths
!define RegUninstall "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}"

