import cPickle as pickle
import numpy as np


water_data = pickle.load(open('/home/pfurlong/data/out/gmm/water-probs.pkl','rb'))
terrain = pickle.load(open('/home/pfurlong/data/out/gmm/terrain_and_water_probs.pkl','rb'))

water_probs = np.vstack(water_data)
terrain_probs = terrain[0]

print water_probs.shape
print terrain_probs.shape

terrain_cov = np.cov(terrain_probs.T)
water_cov = np.cov(water_probs.T)

print terrain_cov
print water_cov

combined = np.hstack((terrain_probs,water_probs))

combined_cov = np.cov(combined.T)
print combined_cov

beta = np.dot(np.linalg.pinv(terrain_probs),water_probs)
print beta

test_error = np.linalg.norm(water_probs - np.dot(terrain_probs,beta),axis=1)
print test_error.shape
print np.mean(test_error)

