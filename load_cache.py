import os
from pyignite import Client

def get_filenames(is_training, data_dir):
  return [
      os.path.join(data_dir, 'data_batch_%d.bin' % i)
      for i in range(1, 6)
  ]

batch_size = 32 * 32 * 3 + 1
idx = 0

client = Client()
client.connect('192.168.1.2', 10800)
cache = client.create_cache('TEST_DATA')

for filename in get_filenames(True, '/tmp/cifar10_data/cifar-10-batches-bin'):
  batch = open(filename, 'rb')
  for _ in range(500):
  #while (True):
     sample = batch.read(batch_size)
     
     if len(sample) == 0:
       break
     elif len(sample) != batch_size:
       raise Exception("Wrong sample size (%d)" % len(sample))
 
     cache.put(idx, sample)
     idx += 1    
