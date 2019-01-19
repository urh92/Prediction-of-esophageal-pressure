# This script implements the LSTM neural network using Tensorflow
# The script consists of two parts; a graph and a session
# The graph contains the code for building the network
# The session contains the training and testing of the network

# Load relevant packages
import load_data_lstm
import tensorflow as tf
from tensorflow.contrib.layers import fully_connected

# Define parameters for the network
rnn_size = 50              # Number of LSTM cells in the network
hm_iterations = 100000     # Number of iterations to train network
check_iterations = 10000   # Number of iterations before each test
time_steps = 100           # Number of windows the network can look back
n_inputs = 35              # Number of features
n_outputs = 1              # Number of outputs
learning_rate = 0.001      # Learning rate

# Load CSV file containing feature matrix and target vector
filename = 'data.csv'
data = load_data_lstm.PSGData(filename=filename, time_steps=time_steps)

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

# Create session for training and testing network
with tf.Session() as sess:

    # Initialize all variables
    tf.global_variables_initializer()

    # Use if a model is to be restored and training resumed
    # saver.restore(sess, "/home/umaer/my-model-100000")

    # Train network iteratively by feeding batches and performing optimization
    total_loss = 0
    for i in range(hm_iterations):
        epoch_x, epoch_y = data.next_batch(batch_type='Train')
        _, c = sess.run([optimizer, cost], feed_dict={x: epoch_x, y: epoch_y, keep_prob: 0.75})
        total_loss += c
        if (i+1) % check_iterations == 0:
            print('Iteration', i+1, 'Completed out of', hm_iterations, 'loss', total_loss / (i+1))

            # Calculate test error after a number of iterations
            test_loss = 0
            for j in range(len(data.test_batch_order)):
                x_test, y_test = data.next_batch(batch_type='Test')
                c1 = cost.eval({x: x_test, y: y_test, keep_prob: 1.0})
                test_loss += c1
            print('Test MSE:', test_loss / len(data.test_batch_order))

            # Save all variables of the model at current iteration
            saver.save(sess, '/home/umaer/my-model', global_step=global_step)

    # Save final model
    save_path = saver.save(sess, "/home/umaer/model.ckpt")
