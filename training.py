import numpy as np
import os
from pathlib import Path
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout, Bidirectional
from tensorflow.keras.callbacks import TensorBoard, EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
from tensorflow.keras.utils import to_categorical
from sklearn.model_selection import train_test_split

# ==============================
# Configuration
# ==============================
DATA_PATH = Path('DATA')
SEQUENCE_LENGTH = 40

# List of actions
actions = np.array(['null','besm allah' , 'alsalam alekom' , 'alekom salam' , 'ahlan w shlan' , 'me',
                    'age','alhamdulilah' , 'bad' , 'how are you' , 'friend' ,
                    'good' , 'happy' , 'you' , 'my name is' , 'no' , 
                    'or' , 'taaban' , 'what' , 'where' , 'yes', 'look' , 'said' , 'walking' , 'did not hear' ,
                      'remind me', 'eat' , 'bayt' , 'hospital' , 'run' , 'sleep',
                       'think' , 'tomorrow' , 'yesterday' , 'today' , 'when','dhuhr' , 'sabah' , 'university' , 'kuliyah' ,'night',])

label_map = {label: idx for idx, label in enumerate(actions)}



# ==============================
# Sequence Loading Function
# ==============================
def normalize_landmarks(landmarks, epsilon=1e-6):
    num_points = len(landmarks) // 3
    landmarks = landmarks.reshape(num_points, 3)

    # Use wrist as anchor for hands and midpoint of hips for pose
    if num_points == 33:  # Pose
        anchor = landmarks[23]  # Left hip
        reference_dist = np.linalg.norm(landmarks[11] - landmarks[12])  # Shoulder width
    elif num_points == 21:  # Hands
        anchor = landmarks[0]  # Wrist
        reference_dist = np.linalg.norm(landmarks[5] - landmarks[17])  # Palm width
    else:
        return landmarks.flatten()  # Return unchanged for unexpected data

    # Handle potential zero or small reference distance
    if reference_dist < epsilon:
        return np.zeros_like(landmarks.flatten())  # Return zeroed-out array for invalid frames

    # Translate (center around anchor)
    landmarks -= anchor

    # Scale (normalize distances)
    landmarks /= reference_dist

    return landmarks.flatten()


sequences, labels = [], []
skip = 5
for action in actions:
    for sequence in np.array(os.listdir(os.path.join(DATA_PATH, action))):

        try:
            if count < skip:
                count +=1
                continue
            sequence = sequence.astype(int)
            window = []
            for frame_num in range(45): # number of frames collected
                res = np.load(os.path.join(DATA_PATH, action, str(sequence), f"{frame_num}.npy"))
                normalized_res = np.concatenate([
                    normalize_landmarks(res[:33*4]),  # Pose landmarks
                    normalize_landmarks(res[33*4:33*4 + 21*3]),  # Left hand landmarks
                    normalize_landmarks(res[33*4 + 21*3:])  # Right hand landmarks
                ])
                window.append(normalized_res)
            sequences.append(window[skip:]) # skip frames
            labels.append(label_map[action])
        except Exception as e:
            print(f"Error in sequence {sequence}: {e}")

# ==============================
# Prepare for Training
# ==============================
X = np.array(sequences)

y = to_categorical(labels).astype(int)
X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, test_size=0.15)

# ==============================
# Callbacks
# ==============================
log_dir = os.path.join('Logs')
callbacks = [
    TensorBoard(log_dir=log_dir),
    EarlyStopping(monitor='val_loss', patience=20, restore_best_weights=True),
    ReduceLROnPlateau(monitor='val_loss', factor=0.7, patience=25, verbose=1),
    ModelCheckpoint('lstm_model.h5', monitor='val_loss', save_best_only=True)
]

# ==============================
# Build BiLSTM Model
# ==============================
from tensorflow.keras.layers import BatchNormalization
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Input
from tensorflow.keras.callbacks import TensorBoard, ReduceLROnPlateau
import tensorflow as tf

model = Sequential()
model.add(Input(shape=(40, 258)))  # define shape here
model.add(LSTM(258, return_sequences=True, activation='tanh'))
model.add(LSTM(258, return_sequences=False, activation='tanh'))
model.add(Dense(258, activation='tanh'))
model.add(Dense(128, activation='tanh'))
model.add(Dense(64, activation='tanh'))
model.add(Dense(actions.shape[0], activation='softmax'))

model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['categorical_accuracy'])

# ==============================
# Train Model
# ==============================
history = model.fit(
    X_train, y_train,
    validation_data=(X_test, y_test),
    epochs=200,
    batch_size=32,
    callbacks=callbacks,
    verbose=1
)

model.save('lstm_model_40_s5.h5')
