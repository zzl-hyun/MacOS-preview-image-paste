# macOS Preview Image Paste

Paste a screenshot or clipboard PNG directly into a PDF opened in Preview on
macOS Tahoe.

The tool converts PNG data into a Preview-compatible AnnotationKit pasteboard
item. It does not automate Preview, click UI elements, or modify the PDF file.

## Requirements

- macOS Tahoe
- Xcode Command Line Tools (`xcode-select --install`)

## Install

```sh
git clone https://github.com/zzl-hyun/MacOS-preview-image-paste.git
cd MacOS-preview-image-paste
chmod +x install.sh uninstall.sh
./install.sh
```

The executable is installed at `~/bin/png2preview`.

## Usage

Capture a region, convert it, then paste it into Preview:

```sh
~/bin/png2preview --capture
```

After selecting a region, return to the PDF in Preview and press `Command-V`.

To convert a PNG that is already on the clipboard:

```sh
~/bin/png2preview
```

The default size accounts for the main display's Retina scale. Override it:

```sh
~/bin/png2preview --capture --scale 0.35
```

## Keyboard shortcut with Automator

Create an Automator **Quick Action** that receives no input in any application,
add **Run Shell Script** with `/bin/zsh`, and use:

```zsh
if "$HOME/bin/png2preview" --capture; then
    /usr/bin/osascript -e 'display notification "Press Command-V in your PDF." with title "Preview image ready"'
else
    /usr/bin/osascript -e 'display notification "Capture cancelled or conversion failed." with title "Preview image failed"'
    exit 1
fi
```

Save it and assign a shortcut under **System Settings → Keyboard → Keyboard
Shortcuts → Services**. The first run may require Screen & System Audio
Recording permission for Automator or Automator Runner.

## Uninstall

```sh
./uninstall.sh
```

## Disclaimer

This project uses an undocumented macOS Preview pasteboard format:
`com.apple.AnnotationKit.AnnotationItem`.

It may stop working after a macOS update. This project is not affiliated with
or endorsed by Apple. It has been tested on macOS Tahoe only.

Do not commit AnnotationKit dumps: they contain the original captured PNG data.

## License

[MIT](LICENSE)
