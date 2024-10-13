# Developer Guide: Adding a New App to the .dotfiles Project

## Introduction

This guide provides step-by-step instructions for adding a new application to the `.dotfiles` project. The project structure automates the installation of applications based on configuration files. This documentation will cover the process of creating a new app directory, configuring its installation, and integrating it with the `install.sh` script.

### Project Structure Overview

Each application to be installed has its own directory inside the `apps` folder, and its installation is controlled by a configuration file (`config.yml`). The installation and configuration process is managed by the `install.sh` script, which reads the app’s configuration file and executes the required installation steps.

---

## Step-by-Step Guide: Adding a New App

### 1. Create the App Directory

1. Navigate to the `apps` folder in the `.dotfiles` project directory.
2. Create a new directory named after the application you want to add. This name will be used by the installation script.
   ```bash
   mkdir -p ~/path/to/dotfiles/apps/your_app
   ```

### 2. Create the `config.yml` File

Each app requires a `config.yml` file that specifies the installation steps and other important information. Below is a basic example of a configuration file:

#### Example `config.yml`

```yaml
name: "your_app"
dependencies:
  - "dependency_1"
  - "dependency_2"
config:
  install_type: "appimage"  # or "curl", "package_manager"
  install_url: "URL_to_download_app"  # URL to download the binary if using AppImage or curl
  install_path: "/usr/local/bin/your_app"  # Path where the app will be installed
  check_installed: "command -v your_app &> /dev/null"  # Command to verify if the app is installed
  get_installed_version: "your_app --version"  # Command to get the installed version (optional)
pre_install: "echo 'Preparing to install YourApp...'"
post_install: "echo 'YourApp installation completed.'"
override_install: false  # Set to true to force reinstall even if the app is already installed
```

### 3. Define Pre- and Post-Installation Steps (Optional)

- **Pre-installation:** This step can be used to perform any actions required before the main installation (e.g., downloading dependencies or configuring the system).
  ```yaml
  pre_install: "echo 'Running pre-installation tasks...'"
  ```

- **Post-installation:** This step can be used to run any final tasks after the main installation, like setting permissions or creating symbolic links.
  ```yaml
  post_install: "echo 'Running post-installation tasks...'"
  ```

### 4. Define the Installation Type

The `install_type` key determines how the application will be installed. Supported types include:

- **`appimage`:** Downloads an AppImage file from a URL and makes it executable.
- **`curl`:** Uses curl to download and install the app.
- **`package_manager`:** Installs the app via a package manager like `apt`, `brew`, or `yum`.

#### Example for AppImage:

```yaml
install_type: "appimage"
install_url: "https://example.com/download/your_app.AppImage"
install_path: "/usr/local/bin/your_app"
```

#### Example for Curl:

```yaml
install_type: "curl"
install_url: "https://example.com/download/your_app.tar.gz"
install_path: "/usr/local/bin/your_app"
```

#### Example for Package Manager:

```yaml
install_type: "package_manager"
package_name: "your_app"
```

### 5. Add Installation Checks

To avoid reinstalling an already installed app, add a check command using the `check_installed` key. This should be a command that verifies if the application is installed on the system.

```yaml
check_installed: "command -v your_app &> /dev/null"
```

You can also define a way to check the installed version using `get_installed_version`:

```yaml
get_installed_version: "your_app --version | awk '{print $2}'"
```

### 6. Process the New App in the `install.sh` Script

The `install.sh` script automatically processes all applications listed in the main configuration file (`dotfiles_config.yml`). Ensure that your app is added to the `apps[]` section in this file.

```yaml
apps:
  - your_app
```

### 7. Test the Installation

After adding the configuration file, you can test the installation process by running the following command:

```bash
./install.sh your_app
```

This will execute the steps defined in the `config.yml` and provide feedback via the logging functions.

---

## Logging Functions

The `install.sh` script includes logging functions that use different colors and symbols to represent information, success, warnings, and errors.

- **`log_info`:** Displays informational messages.
- **`log_success`:** Displays success messages.
- **`log_warning`:** Displays warning messages.
- **`log_error`:** Displays error messages.

Example usage:

```bash
log_info "Starting installation for $app_name"
log_success "$app_name installed successfully"
log_error "Failed to install $app_name"
```

---

## Final Thoughts

By following these steps, you can easily add new apps to the `.dotfiles` project and automate their installation. Each app is modular, and the installation is controlled through the `config.yml` file, making it simple to add, update, or remove applications.

Feel free to customize the `config.yml` for each app as needed, and ensure that you test the installation thoroughly before using it in production environments.