#!/bin/bash

recommended_path="/usr/local/go"

while getopts ":v:p:" opt; do
  case ${opt} in
    v )
      version=$OPTARG
      ;;
    p )
      install_path=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# 如果未指定版本或路径，提供提示并退出
if [ -z "$version" ]; then
  echo "Usage: $0 -v <version_number> -p <installation_path>"
  exit 1
fi

if [ -z "$install_path" ]; then
  install_path=$recommended_path
  echo "No installation path specified. Using default: $install_path"
fi

# 检测操作系统
OS=$(uname -s)
echo "Detected OS: $OS"

# 根绝OS下载文件的URL
if [ "$OS" = "Darwin" ]; then
  file_url="https://dl.google.com/go/$version.darwin-amd64.tar.gz"
elif [ "$OS" = "Linux" ]; then
  file_url="https://dl.google.com/go/$version.linux-amd64.tar.gz"
else
  echo "Unsupported OS"
  exit 1
fi

sudo mkdir -p "$install_path"

echo "Downloading $version from $file_url..."
curl -o "$install_path/$version".tar.gz "$file_url"
if [ $? -ne 0 ]; then
    echo "Failed to download Go."
    exit 1
fi

echo "Installing $version to $install_path..."
sudo tar -C "$install_path" -xzf "$install_path/$version".tar.gz
if [ $? -ne 0 ]; then
    echo "Failed to install Go."
    exit 1
fi

# 设置环境变量
echo "Setting up environment variables..."
if [[ "$SHELL" == *bash* ]]; then
  echo "export PATH=$install_path/go/bin:\$PATH" >> ~/.bash_profile
  source ~/.bash_profile
elif [[ "$SHELL" == *zsh* ]]; then
  echo "export PATH=$install_path/go/bin:\$PATH" >> ~/.zshrc
  source ~/.zshrc
fi

echo "Verifying Go installation..."
"$install_path/go/bin/go" version
if [ $? -ne 0 ]; then
    echo "Go installation failed. Please check the installation steps."
    exit 1
fi

if [[ "$SHELL" == *bash* ]]; then
  source ~/.bash_profile
elif [[ "$SHELL" == *zsh* ]]; then
  source ~/.zshrc
fi

echo "Go $version has been installed successfully!"
