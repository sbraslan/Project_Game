# Admin Panel x64

Target environment: **FreeBSD 14.x amd64, Python 3, GCC 14**.

Run:

    ./admin_panel.sh

or pass an option directly:

    ./admin_panel.sh 890
    ./admin_panel.sh 666
    ./admin_panel.sh 888
    ./admin_panel.sh 1

Main options:

    1 / start       Start DB, auth and configured channels
    1i / starti     Interactive start
    1a / startall   Start daemon supervisor

    2 / stop        Graceful stop
    2i / stopi      Interactive stop
    2a / stopall    Stop daemon and server

    3 / clear       Clean runtime logs
    33 / cleanall   Clean runtime logs and legacy backups

    666 / gen       Generate runtime layout/config/lists
    777 / quest     Preprocess and compile quests with Python 3
    888 / src       Full Project_ServerSRC x64 build and deploy
    889 / srcfast   Incremental x64 build and deploy
    890 / check     Validate amd64, Python 3, gmake and source path
    999 / search    Show generated CONFIG ports

Source discovery order:

    $SERVER_SRC
    ../Project_ServerSRC
    $HOME/Project_ServerSRC
    /usr/home/Project_ServerSRC
    legacy Source/Srcs/Server

Recommended first run:

    ./admin_panel.sh 890
    ./admin_panel.sh 666
    ./admin_panel.sh 888
    ./admin_panel.sh 777
    ./admin_panel.sh 1
