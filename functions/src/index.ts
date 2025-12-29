/**
 * ReceiptVault Cloud Functions
 *
 * This file exports all Cloud Functions for the ReceiptVault app.
 */

import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export functions by category

// Authentication triggers
export { onUserCreate } from './functions/auth/onUserCreate';
export { onUserDelete } from './functions/auth/onUserDelete';

// OCR Processing
export { processReceipt } from './functions/ocr/processReceipt';

// Exchange Rates
export { syncExchangeRates } from './functions/exchange/syncExchangeRates';

// Price Comparison
export { updatePriceIndex } from './functions/price/updatePriceIndex';

// Analytics
export { generateInsights } from './functions/analytics/generateInsights';
