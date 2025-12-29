import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';

const db = admin.firestore();

/**
 * Sync exchange rates from external sources
 * Runs every hour to keep rates updated
 */
export const syncExchangeRates = onSchedule(
  {
    schedule: 'every 1 hours',
    timeZone: 'Asia/Beirut',
    memory: '256MiB',
  },
  async () => {
    logger.info('Starting exchange rate sync');

    try {
      // In production, you would fetch from actual APIs
      // For now, we'll use placeholder values
      const rates = [
        {
          source: 'black_market',
          rateType: 'mid',
          usdToLbp: 89500, // Example rate
        },
        {
          source: 'sayrafa',
          rateType: 'mid',
          usdToLbp: 89500,
        },
      ];

      const batch = db.batch();
      const now = admin.firestore.Timestamp.now();

      // Deactivate old rates
      const activeRates = await db
        .collection('exchange_rates')
        .where('isActive', '==', true)
        .get();

      activeRates.docs.forEach((doc) => {
        batch.update(doc.ref, { isActive: false });
      });

      // Add new rates
      for (const rate of rates) {
        const rateRef = db.collection('exchange_rates').doc();
        batch.set(rateRef, {
          id: rateRef.id,
          date: now,
          source: rate.source,
          rateType: rate.rateType,
          usdToLbp: rate.usdToLbp,
          lbpToUsd: 1 / rate.usdToLbp,
          fetchedAt: now,
          isActive: true,
        });
      }

      await batch.commit();

      logger.info('Exchange rates synced successfully', {
        ratesCount: rates.length,
      });
    } catch (error) {
      logger.error('Failed to sync exchange rates', { error });
      throw error;
    }
  }
);
