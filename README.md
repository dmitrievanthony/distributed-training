### Distributed deep learning with TensorFlow and Apache Ignite

This repository contains a demo of distributed deep learning with TensorFlow and Apache Ignite.

## Initialization

Before you start a demo you need to initialize workspace. The initialization include:

* Downloading and building of Apache Ignite.
* Downloading Cifar10 dataset.
* Downloading official TensorFlow models repository.
* Updating ResNet Cifar10 model (see `models.diff` patch).

To initialize the workspace you can use a single command:

```bash
$ . init.sh
```

To clean the workspace:

```bash
$ clear.sh
```

## Build and start Apache Ignite

When workspace is initialized you can build Apache Ignite Docker image (that includes TensorFlow 1.13.0rc0 and Apache Ignite) using the following command:
The convenient way to start Apache Ignite cluster is to use Docker Compose:

```bash
$ docker-compose build
```

When Docker image is ready you can start Apache Ignite cluster using Docker Compose:

```bash
$ docker-compose up --scale ignite-server=4
```

## Fill cache

When Apache Ignite cluster is running you can fill the cache. You can make it using the following script:

```
python3 load-cache.py
```

## Start training

When cache is filled you can start training. The model is taken from list of official models of TensorFlow and slightly modified:

```
ignite-tf.sh start TEST_DATA models python3 official/resnet/cifar10_main.py
```

The training is started.

## Logs

Logs are saved into IGFS so that you can see them in TensorBoard. TBD.

```diff
public class Test
{
   public static void Main()
   {
-      System.Console.WriteLine("Hello, World!");
+      System.Console.WriteLine("Rock all night long!");
   }
}
```
