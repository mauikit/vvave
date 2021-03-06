#include "vvave.h"

#include "db/collectionDB.h"
#include "services/local/taginfo.h"

#include <MauiKit/fileloader.h>
#include <MauiKit/fm.h>

#include <QTimer>

static FMH::MODEL trackInfo(const QUrl &url)
{
    TagInfo info(url.toLocalFile());
    if (info.isNull())
        return FMH::MODEL();

    const auto track = info.getTrack();
    const auto genre = info.getGenre();
    const auto album = BAE::fixString(info.getAlbum());
    const auto title = BAE::fixString(info.getTitle()); /* to fix*/
    const auto artist = BAE::fixString(info.getArtist());
    const auto sourceUrl = FMH::parentDir(url).toString();
    const auto duration = info.getDuration();
    const auto year = info.getYear();

    FMH::MODEL map = {{FMH::MODEL_KEY::URL, url.toString()},
                      {FMH::MODEL_KEY::TRACK, QString::number(track)},
                      {FMH::MODEL_KEY::TITLE, title},
                      {FMH::MODEL_KEY::ARTIST, artist},
                      {FMH::MODEL_KEY::ALBUM, album},
                      {FMH::MODEL_KEY::DURATION, QString::number(duration)},
                      {FMH::MODEL_KEY::GENRE, genre},
                      {FMH::MODEL_KEY::SOURCE, sourceUrl},
                      {FMH::MODEL_KEY::FAV, "0"},
                      {FMH::MODEL_KEY::RELEASEDATE, QString::number(year)}};

    BAE::artworkCache(map, FMH::MODEL_KEY::ALBUM);
    return map;
}

/*
 * Sets upthe app default config paths
 * BrainDeamon to get collection information
 * YoutubeFetcher ?
 *
 * */
vvave::vvave(QObject *parent)
    : QObject(parent)
    , db(CollectionDB::getInstance())
{
    qRegisterMetaType<QList<QUrl> *>("QList<QUrl>&");

    QDir dirPath(BAE::CachePath.toLocalFile());
    if (!dirPath.exists())
        dirPath.mkpath(".");


    auto tracksTimer = new QTimer(this);
    tracksTimer->setSingleShot(true);
    tracksTimer->setInterval(1000);

    auto albumsTimer = new QTimer(this);
    albumsTimer->setSingleShot(true);
    albumsTimer->setInterval(1000);

    auto artistTimer = new QTimer(this);
    artistTimer->setSingleShot(true);
    artistTimer->setInterval(1000);

    connect(db, &CollectionDB::trackInserted, [this, tracksTimer](QVariantMap) {
        m_newTracks++;
        tracksTimer->start();
    });

    connect(db, &CollectionDB::albumInserted, [this, albumsTimer](QVariantMap) {
        m_newAlbums++;
        albumsTimer->start();
    });

    connect(db, &CollectionDB::artistInserted, [this, artistTimer](QVariantMap) {
        m_newArtist++;
        artistTimer->start();
    });

    connect(db, &CollectionDB::sourceInserted, [this](QVariantMap) {
        m_newSources++;
    });

    connect(tracksTimer, &QTimer::timeout, [this]()
    {
        if (m_newTracks > 0) {
            emit tracksAdded(m_newTracks);
            m_newTracks = 0;
        }
    });

    connect(albumsTimer, &QTimer::timeout, [this]()
    {
        if (m_newAlbums > 0) {
            emit albumsAdded(m_newAlbums);
            m_newAlbums = 0;
        }
    });


    connect(artistTimer, &QTimer::timeout, [this]()
    {
        if (m_newArtist > 0) {
            emit artistsAdded(m_newArtist);
            m_newArtist = 0;
        }
    });
}

//// PUBLIC SLOTS
//vvave *vvave::qmlAttachedProperties(QObject *object)
//{
//    Q_UNUSED(object)
//    return vvave::instance();
//}

void vvave::setFetchArtwork(bool fetchArtwork)
{
    if (m_fetchArtwork == fetchArtwork)
        return;

    m_fetchArtwork = fetchArtwork;
    emit fetchArtworkChanged(m_fetchArtwork);
}

bool vvave::autoScan() const
{
    return m_autoScan;
}

bool vvave::fetchArtwork() const
{
    return m_fetchArtwork;
}

void vvave::addSources(const QList<QUrl> &paths)
{
    auto urls = QUrl::fromStringList(sources());
    QList<QUrl> newUrls;

    for (const auto &path : paths) {
        if (!urls.contains(path)) {
            newUrls << path;
            emit sourceAdded(path);
        }
    }

    if (newUrls.isEmpty())
        return;

    urls << newUrls;
    FMStatic::saveSettings("SETTINGS", QVariant::fromValue(QUrl::toStringList(urls)), "SOURCES");

    scanDir(urls);
    emit sourcesChanged();
}

bool vvave::removeSource(const QString &source)
{
    auto urls = this->sources();
    if (!urls.contains(source))
        return false;

    urls.removeOne(source);
    FMStatic::saveSettings("SETTINGS", QVariant::fromValue(urls), "SOURCES");
    emit sourcesChanged();

    if (this->db->removeSource(source)) {
        emit this->sourceRemoved(source);
        return true;
    }

    return false;
}

void vvave::scanDir(const QList<QUrl> &paths)
{
    auto fileLoader = new FMH::FileLoader();
    fileLoader->informer = &trackInfo;
    //    fileLoader->setBatchCount(50);

    connect(fileLoader, &FMH::FileLoader::itemReady, db, &CollectionDB::addTrack);
    connect(fileLoader, &FMH::FileLoader::finished, fileLoader, &FMH::FileLoader::deleteLater);

    fileLoader->requestPath(paths, true, QStringList() << FMH::FILTER_LIST[FMH::FILTER_TYPE::AUDIO] << "*.m4a");
}

QStringList vvave::sources()
{
    return FMStatic::loadSettings("SETTINGS", "SOURCES", QVariant::fromValue(BAE::defaultSources)).toStringList();
}

QVariantList vvave::sourcesModel()
{
    QVariantList res;
    for (const auto &url : sources())
        res << FMH::getDirInfo(url);

    return res;
}

void vvave::setAutoScan(bool autoScan)
{
    if (m_autoScan == autoScan)
        return;

    m_autoScan = autoScan;
    emit autoScanChanged(m_autoScan);

    if (m_autoScan) {
        scanDir(QUrl::fromStringList(sources()));
    }
}

void vvave::openUrls(const QStringList &urls)
{
    if (urls.isEmpty())
        return;

    QVariantList data;

    for (const auto &url : urls) {
        auto _url = QUrl::fromUserInput(url);
        if (db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], _url.toString())) {
            data << FMH::toMap(this->db->getDBData(QStringList() << _url.toString()).first());
        } else {
            data << FMH::toMap(trackInfo(_url));
        }
    }

    emit this->openFiles(data);
}

QList<QUrl> vvave::folders()
{
    const auto sources = CollectionDB::getInstance()->getDBData("select * from sources");
    return QUrl::fromStringList(FMH::modelToList(sources, FMH::MODEL_KEY::URL));
}

