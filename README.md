### Distributed deep learning with TensorFlow and Apache Ignite

This repository contains a demo of distributed deep learning with TensorFlow and Apache Ignite.

-   [Initialization](#initialization)
-   [Build and start Apache Ignite](#build-and-start-apache-ignite)
-   [Fill cache](#fill-cache)
-   [Start training](#start-training)
-   [TensorBoard](#tensorboard)

## Initialization

Before you start a demo you need to initialize workspace. The initialization include:

* Downloading and building of Apache Ignite.
* Downloading Cifar10 dataset.
* Downloading official TensorFlow models repository.
* Updating ResNet Cifar10 model (see `models.diff` patch).

The model changes required to run the model on Apache Ignite are gathered in `models.diff` patch. Essentially, the changes are following.

We need to replace `tf.data.FixedLengthRecordDataset` by `IgniteDataset`:

```diff
   Returns:
     A dataset that can be used for iteration.
   """
-  filenames = get_filenames(is_training, data_dir)
-  dataset = tf.data.FixedLengthRecordDataset(filenames, _RECORD_BYTES)
+  dataset = IgniteDataset("TEST_DATA", local=True).map(lambda row: row['val'])

   return resnet_run_loop.process_record_dataset(
       dataset=dataset,

```

We need to specify new folder for checkpoints on IGFS filesystem:

```diff
 def define_cifar_flags():
   resnet_run_loop.define_resnet_flags()
   flags.adopt_module_key_flags(resnet_run_loop)
   flags_core.set_defaults(data_dir='/tmp/cifar10_data/cifar-10-batches-bin',
-                          model_dir='/tmp/cifar10_model',
+                          model_dir='igfs:///tmp/cifar10_model',
                           resnet_size='56',
                           train_epochs=182,
-                          epochs_between_evals=10,
+                          epochs_between_evals=1,
                           batch_size=128,
                           image_bytes_as_serving_input=False)

```

And we need to update `RunConfig` to use proper `DistributedStrategy`:

```diff
   run_config = tf.estimator.RunConfig(
-      train_distribute=distribution_strategy,
+      experimental_distribute=tf.contrib.distribute.DistributeConfig(
+        train_distribute=tf.contrib.distribute.CollectiveAllReduceStrategy(),
+        eval_distribute=tf.contrib.distribute.MirroredStrategy(),
+        remote_cluster=json.loads(os.environ['TF_CLUSTER'])
+      ),
```

To initialize the workspace you can use a single command:

```bash
$ . init.sh
```

To clean the workspace:

```bash
$ . clear.sh
```

## Build and start Apache Ignite

When workspace is initialized you can build Apache Ignite Docker image (that includes TensorFlow 1.13.0rc0 and Apache Ignite) using the following command:
The convenient way to start Apache Ignite cluster is to use Docker Compose:

```bash
$ docker-compose build
```

When Docker image is ready you can start Apache Ignite cluster using Docker Compose:

```bash
$ docker-compose up --scale ignite-server=2
```

## Fill cache

When Apache Ignite cluster is up and running you can save Cifar10 dataset into Apache Ignite cluster cache using the following command:

```bash
$ python3 load-cache.py
```

## Start training

When Cifar10 dataset and susccessfully loaded into Apache Ignite cluster cache you can start training:

```
ignite-tf.sh start TEST_DATA models python3 official/resnet/cifar10_main.py
```

*If ignite-tf.sh is not in your `PATH` you can find it by the following path: `./apache-ignite-2.7.0-SNAPSHOT-bin/bin/ignite-tf.sh`.*

The training is started. Your current tab shows you the output of the client script. Docker compose tab shows you logs of worker nodes.

## TensorBoard

Logs are saved into IGFS so that you can see them in TensorBoard. TensorBoard can't work with IGFS out-of-the-box (we're working on it), so you need to slightly modify the starting script. First of all you need to setup correct version of `tensorflow` and `tensorboard`:

```bash
$ pip3 uninstall tenosrflow tensorboard
$ pip3 install tensorflow==1.13.0.rc0
```

After that you need to find the `__init__.py` of `tensorboard`. You can do it using the following command:

```bash
$ pip3 show tensorboard
```

And finally, you need to add the following like into `__init__.py` of `tensorboard`:

```bash
import tensorflow.contrib.ignite.python.ops.igfs_ops
```

When it's done you can start `tensorboard` using the following command:

```bash
. start-tensorboard.sh
```

After that `tensorboard` UI will be available by the following link: [http://localhost:6006](http://localhost:6006).

![accuracy](https://s3.eu-central-1.amazonaws.com/dmitrievanthony-habrahabr/accuracy.png)
![cross-entropy](https://s3.eu-central-1.amazonaws.com/dmitrievanthony-habrahabr/cross-entropy.png)
![train-accuracy](https://s3.eu-central-1.amazonaws.com/dmitrievanthony-habrahabr/train_accuracy.png)
