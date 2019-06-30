#include "service.h"


Service::Service(QObject *parent) : QObject(parent)
{

}

void Service::set(const PULPO::REQUEST &request)
{
    this->request = request;
}

void Service::parse(const QByteArray &array)
{
    switch(this->request.ontology)
    {
    case PULPO::ONTOLOGY::ALBUM:
        this->parseAlbum(array);
        break;
    case PULPO::ONTOLOGY::ARTIST:
        this->parseArtist(array);
        break;
    case PULPO::ONTOLOGY::TRACK:
        this->parseTrack(array);
        break;
    }
}

void Service::retrieve(const QString &url, const QMap<QString, QString> &headers)
{
    if(!url.isEmpty())
    {
        auto downloader = new FMH::Downloader;
        connect(downloader, &FMH::Downloader::dataReady, [&, downloader = std::move(downloader)](QByteArray array)
        {
            //            qDebug()<< "DATA READY << " << array;
            emit this->arrayReady(array);
            downloader->deleteLater();
        });

        //        qDebug()<< "trying to get ASYNC DOWNLOADER for "<< url;
        downloader->getArray(url, headers);
    }
}
