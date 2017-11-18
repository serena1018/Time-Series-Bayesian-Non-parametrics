#load data
from numpy import genfromtxt
import numpy as np
import math
import matplotlib.pyplot as plt


my_data_load = genfromtxt('bitstampUSD_1-min_data_2012-01-01_to_2017-10-20.csv', delimiter=',')
my_data=my_data_load[1:,:]


data_recent_5000000=my_data[3000000:,:]
weightedP_recent_5000000=data_recent_5000000[:,7]
price_recent_5000000=data_recent_5000000[:,4]

m=price_recent_5000000.shape[0]
every=50
price_recent_5000000_new=np.zeros(math.floor(m/every))
for i in range (math.floor(m/every)):
    price_recent_5000000_new[i]=np.sum(price_recent_5000000[i*every:(i+1)*every])/every


plt.plot(price_recent_5000000_new)
plt.ylabel('Bitcoin price recent')
plt.show()

out=price_recent_5000000_new.reshape(price_recent_5000000_new.shape[0],1)
np.savetxt("BitCoin_Prepared.csv", out, delimiter=",")

train_data=out[:600]
vali_data=out[601:801]
test_data=out[802:]

np.savetxt("BitCoin_train.csv", train_data, delimiter=",")
np.savetxt("BitCoin_vali.csv", vali_data, delimiter=",")
np.savetxt("BitCoin_test.csv", test_data, delimiter=",")
