import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';

const db = admin.firestore();

interface SpendingInsight {
  userId: string;
  period: string;
  totalSpentLBP: number;
  totalSpentUSD: number;
  receiptCount: number;
  topCategories: { categoryId: string; amount: number }[];
  topStores: { storeId: string; amount: number }[];
  comparedToLastPeriod: {
    percentChange: number;
    direction: 'up' | 'down' | 'stable';
  };
  generatedAt: admin.firestore.Timestamp;
}

/**
 * Generate weekly spending insights for all users
 * Runs every Monday at 8 AM Beirut time
 */
export const generateInsights = onSchedule(
  {
    schedule: 'every monday 08:00',
    timeZone: 'Asia/Beirut',
    memory: '512MiB',
  },
  async () => {
    logger.info('Starting weekly insights generation');

    try {
      // Get all active users
      const usersSnapshot = await db
        .collection('users')
        .where('isOnboarded', '==', true)
        .get();

      logger.info(`Processing ${usersSnapshot.size} users`);

      const now = new Date();
      const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      const twoWeeksAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);

      for (const userDoc of usersSnapshot.docs) {
        try {
          const userId = userDoc.id;

          // Get receipts from last week
          const receiptsSnapshot = await db
            .collection('receipts')
            .where('userId', '==', userId)
            .where('date', '>=', oneWeekAgo)
            .where('date', '<', now)
            .get();

          // Get receipts from previous week for comparison
          const prevWeekSnapshot = await db
            .collection('receipts')
            .where('userId', '==', userId)
            .where('date', '>=', twoWeeksAgo)
            .where('date', '<', oneWeekAgo)
            .get();

          // Calculate current week totals
          let totalSpentLBP = 0;
          let totalSpentUSD = 0;
          const categorySpending: Record<string, number> = {};
          const storeSpending: Record<string, number> = {};

          receiptsSnapshot.docs.forEach((doc) => {
            const data = doc.data();
            totalSpentLBP += data.totalAmountLBP || 0;
            totalSpentUSD += data.totalAmountUSD || 0;

            const categoryId = data.categoryId || 'other';
            categorySpending[categoryId] = (categorySpending[categoryId] || 0) +
              (data.totalAmountLBP || data.totalAmountUSD || 0);

            const storeId = data.storeId || 'unknown';
            storeSpending[storeId] = (storeSpending[storeId] || 0) +
              (data.totalAmountLBP || data.totalAmountUSD || 0);
          });

          // Calculate previous week total for comparison
          let prevWeekTotal = 0;
          prevWeekSnapshot.docs.forEach((doc) => {
            const data = doc.data();
            prevWeekTotal += data.totalAmountLBP || data.totalAmountUSD || 0;
          });

          const currentTotal = totalSpentLBP || totalSpentUSD;
          let percentChange = 0;
          let direction: 'up' | 'down' | 'stable' = 'stable';

          if (prevWeekTotal > 0) {
            percentChange = ((currentTotal - prevWeekTotal) / prevWeekTotal) * 100;
            if (percentChange > 5) direction = 'up';
            else if (percentChange < -5) direction = 'down';
          }

          // Sort and get top categories and stores
          const topCategories = Object.entries(categorySpending)
            .sort(([, a], [, b]) => b - a)
            .slice(0, 5)
            .map(([categoryId, amount]) => ({ categoryId, amount }));

          const topStores = Object.entries(storeSpending)
            .sort(([, a], [, b]) => b - a)
            .slice(0, 5)
            .map(([storeId, amount]) => ({ storeId, amount }));

          // Save insight
          const insight: SpendingInsight = {
            userId,
            period: `${oneWeekAgo.toISOString().split('T')[0]}_${now.toISOString().split('T')[0]}`,
            totalSpentLBP,
            totalSpentUSD,
            receiptCount: receiptsSnapshot.size,
            topCategories,
            topStores,
            comparedToLastPeriod: {
              percentChange: Math.round(percentChange * 10) / 10,
              direction,
            },
            generatedAt: admin.firestore.Timestamp.now(),
          };

          await db
            .collection('users')
            .doc(userId)
            .collection('insights')
            .doc(insight.period)
            .set(insight);

          logger.info('Insight generated for user', {
            userId,
            receiptCount: insight.receiptCount,
          });
        } catch (userError) {
          logger.error('Failed to generate insight for user', {
            userId: userDoc.id,
            error: userError,
          });
        }
      }

      logger.info('Weekly insights generation completed');
    } catch (error) {
      logger.error('Failed to generate insights', { error });
      throw error;
    }
  }
);
