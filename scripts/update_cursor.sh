#!/bin/bash -e

# Ensure the script runs in the user's context
USER_HOME=$(eval echo ~$SUDO_USER)

# Step 1: Find the latest version of the .AppImage
LATEST_APPIMAGE=$(ls -t $USER_HOME/Applications/cursor-*.AppImage | head -n 1)
if [ -z "$LATEST_APPIMAGE" ]; then
  echo "No AppImage found in $USER_HOME/Applications/"
  exit 1
fi
echo "Latest AppImage: $LATEST_APPIMAGE"

# Step 2: Update symlink to the latest version
SYMLINK_PATH="$USER_HOME/Applications/cursor.AppImage"
ln -sf $LATEST_APPIMAGE $SYMLINK_PATH
echo "Updated symlink to: $SYMLINK_PATH"

# Step 3: Use the manually downloaded icon
ICON_PATH="$USER_HOME/Applications/icons/cursor-icon.png"

# Step 4: Conditionally create or update the .desktop file
DESKTOP_FILE_PATH="$USER_HOME/.local/share/applications/cursor.desktop"
if [ ! -f "$DESKTOP_FILE_PATH" ] || [ "$LATEST_APPIMAGE" != "$(grep -oP '(?<=^Exec=).*' $DESKTOP_FILE_PATH)" ]; then
  DESKTOP_FILE_CONTENT="[Desktop Entry]
Name=Cursor
Exec=$SYMLINK_PATH
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupWMClass=Cursor
X-AppImage-Version=latest
Comment=Cursor is an AI-first coding environment.
MimeType=x-scheme-handler/cursor;
Categories=Development;
"
  echo "$DESKTOP_FILE_CONTENT" > $DESKTOP_FILE_PATH
  chmod +x $DESKTOP_FILE_PATH
  echo "Updated .desktop file at: $DESKTOP_FILE_PATH"
else
  echo ".desktop file is up-to-date."
fi

# Step 5: Validate the .desktop file
desktop-file-validate $DESKTOP_FILE_PATH
echo "Validated .desktop file."
