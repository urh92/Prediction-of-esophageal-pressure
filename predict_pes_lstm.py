# This script performs predictions using the trained LSTM network
# The script is divided into two parts; a graph and a session
# The graph restores all variables from the trained network
# The session performs predictions using a sliding window

# Load relevant packages
import tensorflow as tf
import numpy as np
from scipy.io import savemat
from tensorflow.contrib.layers import fully_connected
from tensorflow.python.platform import gfile
import csv
import matplotlib
matplotlib.use('TkAgg')

# Use same network parameters as during training
rnn_size = 50              # Number of LSTM cells in the network
hm_iterations = 100000     # Number of iterations to train network
check_iterations = 10000   # Number of iterations before each test
time_steps = 100           # Number of windows the network can look back
n_inputs = 35              # Number of features
n_outputs = 1              # Number of outputs
learning_rate = 0.001      # Learning rate

# Define input and output tensors with specified dimensions
x = tf.placeholder('float32', [None, time_steps, n_inputs])
y = tf.placeholder('float32', [None, time_steps, n_outputs])

# Define keep probability tensor for dropout
keep_prob = tf.placeholder("float")

# Create layer consisting of LSTM cells
cell = tf.nn.rnn_cell.BasicLSTMCell(rnn_size)

# Perform dropout at LSTM layer
cell_drop = tf.nn.rnn_cell.DropoutWrapper(cell, input_keep_prob=keep_prob)

# Compute output of LSTM layer by unrolling the layer
outputs, _ = tf.nn.dynamic_rnn(cell_drop, x, dtype=tf.float32)

# Reduce dimensionality of LSTM layer output
stacked_outputs = tf.reshape(outputs, [-1, rnn_size])
stacked_outputs = fully_connected(stacked_outputs, n_outputs, activation_fn=None)
outputs = tf.reshape(stacked_outputs, [-1, time_steps, n_outputs])

# Define mean squared error as cost function
cost = tf.reduce_mean(tf.square(outputs[-1, -1] - y[-1, -1]))

# Define a tensor for tracking the number of iterations
global_step = tf.Variable(0, name='global_step', trainable=False)

# Minimize cost function through gradient descent
optimizer = tf.train.AdamOptimizer(learning_rate).minimize(cost, global_step=global_step)

# Use saver class to save and restore variables of the model
saver = tf.train.Saver()

# Create session for performing predictions
with tf.Session() as sess:

    # Restore the trained model from specified path
    saver.restore(sess, "/Users/umaerhanif/Documents/Speciale/Models/lstm_50_lr_0.001/my-model-300000")
    patient = 0

    # Loop through all patients in the validation set
    for i in range(120):
        filename = '/Users/umaerhanif/PycharmProjects/Main/Validation/patient' + str(patient) + '.csv'

        # Load CSV file containing feature matrix and target vector for current patient
        with gfile.Open(filename) as csv_file:
            data_file = csv.reader(csv_file)
            x_test, y_test = [], []
            for row in data_file:
                y_test.append(row.pop(-1))
                x_test.append(np.asarray(row, dtype=np.float32))
        y_test = np.array(y_test, dtype=np.float32)
        data = np.array(x_test)

        # Initialize sliding window
        rnn_df = []
        rnn_df2 = []

        # Get features and targets in sliding window
        for i in range(len(x_test) - time_steps):
            rnn_df.append(x_test[i: i + time_steps])
            rnn_df2.append(y_test[i + time_steps - 1])

        # Preallocate vector containing predictions
        predictions = np.zeros((len(rnn_df2), 1), dtype=np.float32)

        # Perform predictions in sliding window
        for i in range(len(rnn_df)):
            pred_x = rnn_df[i]
            pred_x = np.reshape(pred_x, [1, time_steps, n_inputs])
            pred_y = rnn_df2[i]
            o = sess.run(outputs, {x: pred_x, keep_prob: 1.0})
            predictions[i] = o[-1, -1]

        # Reshape target vector and prediction vector and concatenate them
        rnn_df2 = np.reshape(rnn_df2, [1, len(rnn_df2)])
        predictions = np.reshape(predictions, [1, len(predictions)])
        pes = np.concatenate((rnn_df2, predictions))

        # Save the result as a mat file
        mat_name = 'p' + str(patient) + 'prediction.mat'
        vec_name = 'p' + str(patient)
        savemat(mat_name, {vec_name: pes})

        patient += 1
