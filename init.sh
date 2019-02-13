if [ -d ./ignite ]
then
    echo "Apache Ignite already downloaded..."
else
    echo "Downloading Apache Ignite..."
    git clone https://github.com/apache/ignite.git
    cd ignite
    git checkout ea33ec7f0af8fcad113cd92953fba0e8e5502dfa
    cd ..
fi

if [ -d ./apache-ignite-2.7.0-SNAPSHOT-bin ]
then
    echo "Apache Ignite already built..."
else
    echo "Building Apache Ignite..."
    cd ignite
    mvn clean package -q -B -DskipTests -Prelease

    echo "Unzipping Apache Ignite package..."
    cd ..
    mv ignite/target/bin/apache-ignite-2.7.0-SNAPSHOT-bin.zip ./
    unzip -qo apache-ignite-2.7.0-SNAPSHOT-bin.zip
    rm apache-ignite-2.7.0-SNAPSHOT-bin.zip
fi

echo "Updating path..."
cd apache-ignite-2.7.0-SNAPSHOT-bin/bin
export PATH=`pwd`:$PATH
cd ../..

echo "Downloading cifar10..."
python3 cifar10_download_and_extract.py

echo "Downloading models..."
rm -rf models
git clone https://github.com/tensorflow/models.git --depth 1 --branch r1.13.0
rm -rf models/research models/samples models/tutorials models/.git
patch -p0 < models.diff

echo "Initialization completed"
