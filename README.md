### Distributed deep learning with TensorFlow and Apache Ignite

This repository contains code that demonstrates how to work with distributed deep learning with TensorFlow and Apache Ignite.

## Initialization

To initialize the workspace you need to run `init.sh` script that downloads and builds Apache Ignite and downloads Cifar10.

## Build and start Apache Ignite

The convenient way to start Apache Ignite cluster is to use Docker Compose:

```
docker-compose build
docker-compose up --scale ignite-server=4

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
