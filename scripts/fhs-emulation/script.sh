shell_home=$HOME/Documents/tmphome

[ -d $shell_home ] || mkdir -p $shell_home

if [ ! -d $shell_home/VSCode-linux-x64 ]
then
    cd $shell_home \
        && curl -L -o code.tar.gz 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' \
        && tar -xvzf ./code.tar.gz \
        && rm -f ./code.tar.gz \
        && cd -
fi

if [ ! -d $shell_home/idea-IC-242.20224.300 ]
then
    cd $shell_home \
        && curl -L -o idea.tar.gz "https://download.jetbrains.com/idea/ideaIC-2024.2.tar.gz?_gl=1*1caj5ew*_ga*MTAwNDAxNTI1Ny4xNzIzMzc3MDMw*_ga_9J976DJZ68*MTcyMzM3NzAzMC4xLjEuMTcyMzM3NzA0Ny4wLjAuMA.." \
        && tar -xvzf ./idea.tar.gz \
        && rm -f ./idea.tar.gz \
        && cd -
fi

cd ~ && guix shell --network --container --emulate-fhs \
             --preserve='^DISPLAY$' --preserve='^XAUTHORITY$' --expose=$XAUTHORITY \
             --preserve='^DBUS_' --expose=/var/run/dbus \
             --expose=/sys/dev --expose=/sys/devices --expose=/dev/dri \
             --development ungoogled-chromium \
             bash coreutils curl grep nss-certs gcc-toolchain git node \
             --share=$shell_home=$HOME
