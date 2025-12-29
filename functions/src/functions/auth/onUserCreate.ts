import { auth } from 'firebase-functions';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';

const db = admin.firestore();

/**
 * Triggered when a new user is created in Firebase Auth.
 * Creates the user document in Firestore with default settings.
 */
export const onUserCreate = auth.user().onCreate(async (user) => {
  const { uid, email, displayName, photoURL, phoneNumber } = user;

  logger.info('Creating user document', { uid, email });

  try {
    // Create user document
    await db.collection('users').doc(uid).set({
      id: uid,
      email: email || null,
      displayName: displayName || null,
      photoUrl: photoURL || null,
      phoneNumber: phoneNumber || null,
      preferredCurrency: 'LBP', // Default to Lebanese Pounds
      preferredLanguage: 'en',
      subscriptionTier: 'free',
      subscriptionExpiry: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastSyncAt: null,
      totalReceipts: 0,
      totalSpendingLBP: 0,
      totalSpendingUSD: 0,
      fcmTokens: [],
      isOnboarded: false,
    });

    // Create default preferences
    await db.collection('users').doc(uid).collection('preferences').doc('settings').set({
      theme: 'system',
      defaultStore: null,
      budgetAlerts: true,
      priceDropAlerts: false,
      weeklyReport: true,
      autoScan: true,
      autoCategorizationEnabled: true,
      defaultCategories: ['groceries', 'fuel', 'dining', 'utilities', 'other'],
    });

    logger.info('User document created successfully', { uid });
  } catch (error) {
    logger.error('Failed to create user document', { uid, error });
    throw error;
  }
});
