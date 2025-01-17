#!/bin/zsh

source ~/.macsetup/base.sh


print_cyan "
Shell 脚本会自动安装和初始化开发环境 (已安装的不会重复安装, 自动备份已有配置项)
- 安装 Homebrew
- 安装必要的可执行程序 (wget, autojump, cmake, gawk, node...)
- 安装必要的 App (iTerm2, Chrome, WeChat, SourceTree, Visual Studio Code)
- 配置 Git
- 安装 oh-my-zsh
- 安装 Python 虚拟环境
- 安装 Java OpenJDK 11, 17, 21
- 安装 Android 开发环境 (可选)
- 安装推荐的 App (可选)(DB Browser, SwitchHosts, draw.io, Hidden Bar, IINA, KeyCastr, Motrix, Obsidian, Only Switch)
"

echo -n "\n${tty_green}是否安装 Android 开发环境 (y/n): ${tty_reset}"
read IS_SETUP_ANDROID

if [[ $IS_SETUP_ANDROID == "y" ]]; then
    echo -n "\n${tty_green}是否安装 Android 开发扩展工具 (反编译等程序) (y/n): ${tty_reset}"
    read IS_SETUP_ANDROID_TOOL
else
    IS_SETUP_ANDROID_TOOL=n
fi

echo -n "\n${tty_green}是否安装 推荐的 App (建议选择)(y/n): ${tty_reset}"
read IS_INSTALL_RECOMMEND_APP


USER_PWD=""
jdk=$(ls /Library/Java/JavaVirtualMachines/microsoft-* |grep jdk)
if [[ $jdk == "" ]]; then
    # print_red "You have not installed open jdk"
    echo -n "\n${tty_green}请输入用户密码: ${tty_reset}"
    read -s USER_PWD
fi


echo ""
git_name=$(git config user.name)
git_email=$(git config user.email)
if [[ -z $git_name ]] || [[ -z $git_email ]]; then
    echo -n "${tty_green}请输入 Git 用户名 (例如: hua.li): ${tty_reset}"
    read GIT_USERNAME

    echo -n "${tty_green}请输入 Git 邮箱 (例如: hua.li@gmail.com): ${tty_reset}"
    read GIT_EMAIL

    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"
else
    print_yellow "Current git user name=$git_name, email=$git_email"
fi


echo ""
if [[ $(sysctl -n machdep.cpu.brand_string) =~ "Apple" ]]; then
    bin_path=/opt/homebrew/bin
else
    bin_path=/usr/local/bin
fi
if [[ ! -e $bin_path/brew ]]; then
    echo -n "${tty_green}请选择 Homebrew 安装源
    1. 国外源 (有代理时的最佳选择)
    2. 国内源 (访问外网不通畅时建议使用) ${tty_reset}"

    echo -n "${tty_green}请输入序号: ${tty_reset}"
    read SOURCE_TYPE

    if [[ $SOURCE_TYPE == "1" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    else
        /bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
        # # change source && avoid prompt && quiet install
        # /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | sed 's/https:\/\/github.com\/Homebrew\/brew/git:\/\/mirrors.ustc.edu.cn\/brew.git/g' | sed 's/https:\/\/github.com\/Homebrew\/homebrew-core/git:\/\/mirrors.ustc.edu.cn\/homebrew-core.git/g' | sed 's/\"fetch\"/\"fetch\", \"-q\"/g')" < /dev/null > /dev/null

        # # Change source
        # cd "$(brew --repo)"
        # git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
        # cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
        # git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
        # export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
    fi
else
    print_yellow "You have installed brew"
fi


echo ""

bash install-formulae.sh

bash install-cask-required.sh

bash env/bin_links.sh

bash env/git_config.sh

bash env/oh_my_zsh.sh &

bash env/python_venv.sh &

if [[ $USER_PWD != "" ]]; then
    bash env/open_jdk_install.sh $USER_PWD
fi

if [[ $IS_SETUP_ANDROID == "y" ]]; then
    bash install-android.sh &
fi

if [[ $IS_SETUP_ANDROID_TOOL == "y" ]]; then
    bash install-android-tools.sh &
fi

if [[ $IS_INSTALL_RECOMMEND_APP == "y" ]]; then
    bash install-cask-recommend.sh &
fi

wait
