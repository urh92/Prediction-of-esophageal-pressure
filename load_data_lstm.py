# This class loads the feature matrix and target vector stored in a CSV file
# It contains methods for dividing the data into training and test batches
# It also contains methods for shuffling and retrieving batches for training

# Load relevant packages
import numpy as np
from tensorflow.python.platform import gfile
import csv

# Define class with all its variables
class PSGData:

    def __init__(self, filename, time_steps):
        self.filename = filename
        self.time_steps = time_steps
        self.features = []
        self.targets = []
        self.n_samples = 5136827
        self.n_features = 35
        self.n_outputs = 1
        self.num_batches = 0
        self.train_iteration = -1
        self.test_iteration = -1
        self.train_batch_order = np.array([])
        self.test_batch_order = np.array([])
        self.split_data()

    # Define method for loading CSV file containing features and targets
    def load_csv(self, filename, features_dtype, target_dtype):

        with gfile.Open(filename) as csv_file:
            data_file = csv.reader(csv_file)
            data = np.zeros((self.n_samples, self.n_features), dtype=features_dtype)
            target = np.zeros((self.n_samples, ), dtype=target_dtype)

            for i, row in enumerate(data_file):
                target[i] = np.asarray(row.pop(-1), dtype=target_dtype)
                data[i] = np.asarray(row, dtype=features_dtype)

            return data, target

    # Define method for splitting data into training and test sets
    def split_data(self):

        features, targets = self.load_csv(self.filename, features_dtype=np.float32, target_dtype=np.float32)
        self.features = features
        self.targets = targets
        self.num_batches = len(targets)/self.time_steps
        batch_order = np.arange(self.num_batches)
        self.train_batch_order = np.random.permutation(batch_order[0:42123])
        self.test_batch_order = batch_order[42123:len(batch_order)]

    # Define method for reshuffling training batches when epoch is completed
    def new_epoch(self):

        self.train_iteration = -1
        self.train_batch_order = np.random.permutation(self.train_batch_order)

    # Define method for resetting iterations for the test batches
    def new_test(self):

        self.test_iteration = -1

    # Define method for reshaping training batch to match input required to LSTM
    def get_train_batch(self, batch_idx):

        batch_num = self.train_batch_order[batch_idx]
        idx = np.arange(batch_num*self.time_steps, (batch_num+1)*self.time_steps, step=1, dtype=np.int)
        x = self.features[idx, :]
        x = np.reshape(x, newshape=[-1, self.time_steps, self.n_features], order='F')
        y = self.targets[idx]
        y = np.reshape(y, newshape=[-1, self.time_steps, self.n_outputs])

        return x, y

    # Define method for reshaping test batch to match input required to LSTM
    def get_test_batch(self, batch_idx):

        batch_num = self.test_batch_order[batch_idx]
        idx = np.arange(batch_num*self.time_steps, (batch_num+1)*self.time_steps, step=1, dtype=np.int)
        x = self.features[idx, :]
        x = np.reshape(x, newshape=[-1, self.time_steps, self.n_features], order='F')
        y = self.targets[idx]
        y = np.reshape(y, newshape=[-1, self.time_steps, self.n_outputs])

        return x, y

    # Define method for getting the next batch (either training or test)
    def next_batch(self, batch_type):

        if batch_type == 'Train':
            self.train_iteration += 1
            if (self.train_iteration + 1) > len(self.train_batch_order):
                self.new_epoch()
            x, y = self.get_train_batch(self.train_iteration)

        elif batch_type == 'Test':
            self.test_iteration += 1
            if (self.test_iteration + 1) > len(self.test_batch_order):
                self.new_test()
            x, y = self.get_test_batch(self.test_iteration)

        return x, y
