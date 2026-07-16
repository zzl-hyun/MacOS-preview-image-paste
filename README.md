# MacOS-preview-image-paste

[English](README.md) | 한국어

## macOS Sequoia에선 잘만 되던게 Toahoe에서 안먹혀서 개빡쳐서 만든 툴

- 이 도구는 PNG 이미지 데이터를 미리보기에 호환되는 AnnotationKit 객체로
변환합니다. <br> - 미리보기 앱을 자동으로 조작하거나 UI 요소를 클릭하지 않으며,
PDF 파일 자체를 직접 수정하지도 않습니다.

## 요구 사항

- macOS Tahoe
- Xcode Command Line Tools (`xcode-select --install`)

## 설치

```sh
git clone https://github.com/zzl-hyun/MacOS-preview-image-paste.git
cd MacOS-preview-image-paste
chmod +x install.sh uninstall.sh
./install.sh
```

실행 파일은 `~/bin/png2preview`에 설치됩니다.

## 사용법

화면의 일부를 캡처하고 변환하려면 다음 명령을 실행합니다.

```sh
~/bin/png2preview --capture
```

영역을 선택한 뒤 미리보기에서 PDF로 돌아가 `Command-V`를 누르세요.

클립보드에 이미 PNG 이미지가 있다면 다음과 같이 실행합니다.

```sh
~/bin/png2preview
```

기본 크기는 주 화면의 Retina 배율에 맞춰 자동으로 계산됩니다. 필요한 경우
배율을 직접 지정할 수 있습니다.

```sh
~/bin/png2preview --capture --scale 0.35
```

## Automator로 단축키 만들기

Automator에서 모든 응용 프로그램을 대상으로 하고 입력을 받지 않는
**빠른 동작**을 만드세요. `/bin/zsh`를 사용하는 **셸 스크립트 실행** 동작을
추가한 뒤 다음 내용을 입력합니다.

```zsh
if "$HOME/bin/png2preview" --capture; then
    /usr/bin/osascript -e 'display notification "PDF에서 Command-V를 누르세요." with title "미리보기 이미지 준비 완료"'
else
    /usr/bin/osascript -e 'display notification "캡처가 취소되었거나 변환에 실패했습니다." with title "미리보기 이미지 변환 실패"'
    exit 1
fi
```

빠른 동작을 저장한 다음 **시스템 설정 → 키보드 → 키보드 단축키 → 서비스**에서
원하는 단축키를 지정하세요. 처음 실행할 때 Automator 또는 Automator Runner에
화면 및 시스템 오디오 녹화 권한을 허용해야 할 수 있습니다.

## 삭제

```sh
./uninstall.sh
```

## 주의 사항

이 프로젝트는 문서화되지 않은 macOS 미리보기 클립보드 형식을 사용합니다.

`com.apple.AnnotationKit.AnnotationItem`

macOS 업데이트 후 작동하지 않을 수 있습니다. 이 프로젝트는 Apple과 제휴하거나
Apple의 보증을 받지 않았으며, macOS Tahoe에서만 테스트되었습니다.

AnnotationKit 덤프에는 원본으로 캡처한 PNG 데이터가 포함되므로 저장소에
커밋하지 마세요.

## 라이선스

[MIT](LICENSE)
