import { auth } from 'firebase-functions';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';

const db = admin.firestore();
const storage = admin.storage();

/**
 * Triggered when a user is deleted from Firebase Auth.
 * Cleans up all user data from Firestore and Storage.
 */
export const onUserDelete = auth.user().onDelete(async (user) => {
  const { uid } = user;

  logger.info('Cleaning up user data', { uid });

  try {
    // Delete user's receipts
    const receiptsSnapshot = await db
      .collection('receipts')
      .where('userId', '==', uid)
      .get();

    const batch = db.batch();
    receiptsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete user's budgets
    const budgetsSnapshot = await db
      .collection('budgets')
      .where('userId', '==', uid)
      .get();

    budgetsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete user document and subcollections
    batch.delete(db.collection('users').doc(uid));

    await batch.commit();

    // Delete user's files from Storage
    try {
      await storage.bucket().deleteFiles({
        prefix: `users/${uid}/`,
      });
    } catch (storageError) {
      logger.warn('Failed to delete storage files', { uid, storageError });
    }

    logger.info('User data cleaned up successfully', { uid });
  } catch (error) {
    logger.error('Failed to clean up user data', { uid, error });
    throw error;
  }
});
