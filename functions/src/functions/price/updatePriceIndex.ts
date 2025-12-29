import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';

const db = admin.firestore();

/**
 * Update price index when a new price is reported
 * Triggered when a new document is created in the prices subcollection
 */
export const updatePriceIndex = onDocumentCreated(
  'products/{productId}/prices/{priceId}',
  async (event) => {
    const { productId, priceId } = event.params;
    const priceData = event.data?.data();

    if (!priceData) {
      logger.warn('No price data found', { productId, priceId });
      return;
    }

    logger.info('Updating price index', { productId, priceId });

    try {
      const { storeId, priceLBP, priceUSD, recordedAt } = priceData;
      const price = priceLBP || priceUSD || 0;
      const currency = priceLBP ? 'LBP' : 'USD';

      // Get or create price index document
      const indexRef = db.collection('price_index').doc(productId);
      const indexDoc = await indexRef.get();

      if (!indexDoc.exists) {
        // Create new index
        await indexRef.set({
          productId,
          stores: {
            [storeId]: {
              currentPrice: price,
              currency,
              priceHistory: [{ price, date: recordedAt, currency }],
              trend: 'stable',
              lastUpdated: recordedAt,
            },
          },
          lowestPrice: {
            storeId,
            price,
            currency,
          },
          averagePrice: price,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing index
        const indexData = indexDoc.data()!;
        const stores = indexData.stores || {};

        // Update store's price data
        const storeData = stores[storeId] || {
          priceHistory: [],
          trend: 'stable',
        };

        const newHistory = [
          { price, date: recordedAt, currency },
          ...(storeData.priceHistory || []).slice(0, 29), // Keep last 30 prices
        ];

        // Calculate trend
        let trend: 'up' | 'down' | 'stable' = 'stable';
        if (newHistory.length >= 2) {
          const priceDiff = newHistory[0].price - newHistory[1].price;
          const threshold = newHistory[1].price * 0.05; // 5% threshold
          if (priceDiff > threshold) trend = 'up';
          else if (priceDiff < -threshold) trend = 'down';
        }

        stores[storeId] = {
          currentPrice: price,
          currency,
          priceHistory: newHistory,
          trend,
          lastUpdated: recordedAt,
        };

        // Find lowest price across all stores
        let lowestPrice = { storeId, price, currency };
        for (const [sid, sdata] of Object.entries(stores) as [string, any][]) {
          // Normalize to same currency for comparison (simplified)
          if (sdata.currentPrice < lowestPrice.price) {
            lowestPrice = {
              storeId: sid,
              price: sdata.currentPrice,
              currency: sdata.currency,
            };
          }
        }

        // Calculate average
        const prices = Object.values(stores).map((s: any) => s.currentPrice);
        const averagePrice = prices.reduce((a, b) => a + b, 0) / prices.length;

        await indexRef.update({
          stores,
          lowestPrice,
          averagePrice,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      logger.info('Price index updated', { productId, storeId, price });
    } catch (error) {
      logger.error('Failed to update price index', { productId, error });
      throw error;
    }
  }
);
