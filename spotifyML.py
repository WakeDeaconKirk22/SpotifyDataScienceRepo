#Import libraries

from sklearn.metrics import accuracy_score,confusion_matrix
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler, StandardScaler
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
import pandas as pd
import matplotlib.pylab as plt 
import seaborn as sns



#load dataset

spotify = pd.read_csv("cleaned_dataset.csv")



#Standardise the data 

spotify.describe()




#Quick Look

print(spotify.head())
print(spotify.info())


# Can use views,likes,stream,comments
# popularity according to Billboard is multiscaler so its based off of views,streams,likes

popularity_features = spotify[['Views','Likes','Stream']]

scaler = MinMaxScaler()
popularity_scaled = scaler.fit_transform(popularity_features)

spotify['popularity_score'] = popularity_scaled.mean(axis=1)

threshold = spotify['popularity_score'].quantile(.75)
spotify['is_hit'] = (spotify['popularity_score']>=threshold).astype(int)

print(spotify[['Views', 'Likes', 'Stream', 'popularity_score', 'is_hit']].head(10))

#select features for prediction
features = [
    'Danceability', 'Energy', 'Acousticness', 'Valence',
    'Tempo', 'Speechiness', 'Liveness', 'Instrumentalness',
    'Loudness', 'Duration_min'
]








#optional drop rows with missing values
X = spotify[features]
Y = spotify['is_hit']

#Train-test split
X_train,X_test,Y_train,Y_test = train_test_split(X,Y,test_size=0.2,random_state =42)

#Feature scaling
X_train_scaled = scaler.fit_transform(X_train)

X_test_scaled = scaler.transform(X_test)

#Train classifier (Logistic Regression)
model= LogisticRegression()
model.fit(X_train_scaled,Y_train)
#Predict and evaluate
Y_pred= model.predict(X_test_scaled)

print("Accuracy:", accuracy_score(Y_test,Y_pred))
#10 confusion matrix

cm =confusion_matrix(Y_test,Y_pred)
plt.figure(figsize=(6,4))
sns.heatmap(cm,annot=True,fmt="d",cmap="Blues",xticklabels=["Not Hit","Hit"],yticklabels=["Not Hit","Hit"])
plt.title("confusion_matrix")
plt.xlabel("Predicted Label")
plt.ylabel("True Label")
plt.tight_layout()
plt.show()


#Clustering on a Kmeans

X_scaled_all= scaler.fit_transform(spotify[features])

kmeans= KMeans(n_clusters=3,random_state=42)
clusters=kmeans.fit_predict(X_scaled_all)

spotify['cluster'] = clusters


pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_scaled_all)

plt.figure(figsize=(8,6))
scatter=plt.scatter(X_pca[:,0],X_pca[:,1], c=clusters, cmap='viridis',alpha=0.6)
plt.title("K means clustering of Songs")
plt.xlabel("PCA component 1")
plt.ylabel("Component 2")
plt.colorbar(scatter,label='Cluster')
plt.tight_layout()
plt.show()
