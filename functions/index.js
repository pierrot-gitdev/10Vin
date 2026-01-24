const { onDocumentCreated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Increment counts when a follow relation is created.
exports.onFollowCreate = onDocumentCreated(
  "users/{followerId}/following/{followeeId}",
  async (event) => {
    const { followerId, followeeId } = event.params;
    if (!followerId || !followeeId || followerId === followeeId) {
      return null;
    }

    const followerRef = db.collection("users").document(followerId);
    const followeeRef = db.collection("users").document(followeeId);

    return db.runTransaction(async (tx) => {
      tx.update(followerRef, {
        followingCount: admin.firestore.FieldValue.increment(1),
      });
      tx.update(followeeRef, {
        followersCount: admin.firestore.FieldValue.increment(1),
      });
    });
  }
);

// Decrement counts when a follow relation is removed.
exports.onFollowDelete = onDocumentDeleted(
  "users/{followerId}/following/{followeeId}",
  async (event) => {
    const { followerId, followeeId } = event.params;
    if (!followerId || !followeeId || followerId === followeeId) {
      return null;
    }

    const followerRef = db.collection("users").document(followerId);
    const followeeRef = db.collection("users").document(followeeId);

    return db.runTransaction(async (tx) => {
      tx.update(followerRef, {
        followingCount: admin.firestore.FieldValue.increment(-1),
      });
      tx.update(followeeRef, {
        followersCount: admin.firestore.FieldValue.increment(-1),
      });
    });
  }
);
