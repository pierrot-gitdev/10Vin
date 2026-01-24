const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Increment counts when a follow relation is created.
exports.onFollowCreate = functions.firestore
  .document("users/{followerId}/following/{followeeId}")
  .onCreate(async (snap, context) => {
    const { followerId, followeeId } = context.params;
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
  });

// Decrement counts when a follow relation is removed.
exports.onFollowDelete = functions.firestore
  .document("users/{followerId}/following/{followeeId}")
  .onDelete(async (snap, context) => {
    const { followerId, followeeId } = context.params;
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
  });
