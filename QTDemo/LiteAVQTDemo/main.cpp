#include "mainwindow.h"
#include <QApplication>
#include<TXLiteAVSDK_TRTC_Mac/cpp_interface/ITRTCCloud.h>
int main(int argc, char *argv[])
{
    liteav ::ITRTCCloud *trtc = liteav::ITRTCCloud::getTRTCShareInstance();
    trtc->startLocalPreview(nullptr);
    QApplication a(argc, argv);
    MainWindow w;
    w.show();
    return a.exec();
}
