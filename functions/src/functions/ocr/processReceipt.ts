import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { ImageAnnotatorClient } from '@google-cloud/vision';
import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions';
import { z } from 'zod';

const db = admin.firestore();
const vision = new ImageAnnotatorClient();

// Request validation schema
const ProcessReceiptRequest = z.object({
  imageUrl: z.string().url(),
  userId: z.string().min(1),
});

// Lebanese store patterns
const STORE_PATTERNS: Record<string, RegExp> = {
  spinneys: /spinneys|سبينيز/i,
  happy: /happy|هابي/i,
  al_makhazen: /al.?makhazen|المخازن/i,
  charcutier_aoun: /charcutier|aoun|عون/i,
  total: /total|توتال/i,
  medco: /medco|ميدكو/i,
};

// Price patterns
const PRICE_PATTERN = /([\d,]+(?:\.\d{2})?)\s*(LBP|L\.L\.|ل\.ل|USD|\$|دولار)?/gi;
const DATE_PATTERNS = [
  /(\d{2})\/(\d{2})\/(\d{4})/,
  /(\d{4})-(\d{2})-(\d{2})/,
  /(\d{2})-(\d{2})-(\d{4})/,
];

interface ExtractedReceipt {
  storeName: string | null;
  storeId: string | null;
  date: string | null;
  items: ExtractedItem[];
  totalLBP: number | null;
  totalUSD: number | null;
  currency: 'LBP' | 'USD';
  rawText: string;
  confidence: number;
}

interface ExtractedItem {
  name: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  confidence: number;
}

/**
 * Process a receipt image using Google Cloud Vision API
 */
export const processReceipt = onCall(
  {
    memory: '512MiB',
    timeoutSeconds: 60,
    maxInstances: 10,
  },
  async (request) => {
    // Verify authentication
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Validate request
    const parseResult = ProcessReceiptRequest.safeParse(request.data);
    if (!parseResult.success) {
      throw new HttpsError('invalid-argument', 'Invalid request data');
    }

    const { imageUrl, userId } = parseResult.data;

    // Verify user owns the request
    if (request.auth.uid !== userId) {
      throw new HttpsError('permission-denied', 'Cannot process receipt for another user');
    }

    logger.info('Processing receipt', { userId, imageUrl: imageUrl.substring(0, 50) });

    try {
      // Call Vision API
      const [result] = await vision.documentTextDetection(imageUrl);
      const fullText = result.fullTextAnnotation?.text || '';
      const confidence = calculateConfidence(result);

      logger.info('OCR completed', { textLength: fullText.length, confidence });

      // Parse the receipt
      const extractedData = parseReceipt(fullText, confidence);

      // Save to Firestore
      const receiptRef = db.collection('receipts').doc();
      await receiptRef.set({
        id: receiptRef.id,
        userId,
        storeName: extractedData.storeName || 'Unknown Store',
        storeId: extractedData.storeId,
        date: extractedData.date ? new Date(extractedData.date) : admin.firestore.FieldValue.serverTimestamp(),
        totalAmountLBP: extractedData.totalLBP,
        totalAmountUSD: extractedData.totalUSD,
        originalCurrency: extractedData.currency,
        status: confidence > 0.8 ? 'processed' : 'pending',
        ocrConfidence: confidence,
        rawOcrText: fullText,
        imageUrls: [imageUrl],
        isStitched: false,
        sourceImages: 1,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        syncedAt: admin.firestore.FieldValue.serverTimestamp(),
        isOfflineCreated: false,
      });

      // Save items
      const itemsBatch = db.batch();
      extractedData.items.forEach((item, index) => {
        const itemRef = receiptRef.collection('items').doc();
        itemsBatch.set(itemRef, {
          id: itemRef.id,
          receiptId: receiptRef.id,
          name: item.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.totalPrice,
          currency: extractedData.currency,
          ocrConfidence: item.confidence,
          isManuallyEdited: false,
          position: index,
        });
      });
      await itemsBatch.commit();

      // Update user stats
      await db.collection('users').doc(userId).update({
        totalReceipts: admin.firestore.FieldValue.increment(1),
        [`totalSpending${extractedData.currency}`]: admin.firestore.FieldValue.increment(
          extractedData.currency === 'LBP' ? (extractedData.totalLBP || 0) : (extractedData.totalUSD || 0)
        ),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      logger.info('Receipt saved', { receiptId: receiptRef.id, itemCount: extractedData.items.length });

      return {
        success: true,
        receiptId: receiptRef.id,
        data: extractedData,
      };
    } catch (error) {
      logger.error('Failed to process receipt', { userId, error });
      throw new HttpsError('internal', 'Failed to process receipt');
    }
  }
);

/**
 * Calculate overall confidence score from Vision API result
 */
function calculateConfidence(result: any): number {
  const pages = result.fullTextAnnotation?.pages || [];
  if (pages.length === 0) return 0;

  let totalConfidence = 0;
  let blockCount = 0;

  for (const page of pages) {
    for (const block of page.blocks || []) {
      if (block.confidence) {
        totalConfidence += block.confidence;
        blockCount++;
      }
    }
  }

  return blockCount > 0 ? totalConfidence / blockCount : 0;
}

/**
 * Parse extracted text into structured receipt data
 */
function parseReceipt(text: string, confidence: number): ExtractedReceipt {
  const lines = text.split('\n').map((line) => line.trim()).filter(Boolean);

  // Detect store
  let storeName: string | null = null;
  let storeId: string | null = null;

  for (const [id, pattern] of Object.entries(STORE_PATTERNS)) {
    if (pattern.test(text)) {
      storeId = id;
      storeName = id.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
      break;
    }
  }

  // Detect date
  let date: string | null = null;
  for (const pattern of DATE_PATTERNS) {
    const match = text.match(pattern);
    if (match) {
      // Normalize to ISO format
      if (match[1].length === 4) {
        date = `${match[1]}-${match[2]}-${match[3]}`;
      } else if (match[3].length === 4) {
        date = `${match[3]}-${match[2]}-${match[1]}`;
      }
      break;
    }
  }

  // Detect currency
  const hasLBP = /LBP|L\.L\.|ل\.ل/i.test(text);
  const hasUSD = /USD|\$/i.test(text);
  const currency: 'LBP' | 'USD' = hasUSD && !hasLBP ? 'USD' : 'LBP';

  // Extract items (simplified - real implementation would be more sophisticated)
  const items: ExtractedItem[] = [];
  const priceMatches = [...text.matchAll(PRICE_PATTERN)];

  // Extract total (usually the largest number at the bottom)
  let total: number | null = null;
  const totalsPatterns = [/total|المجموع|الإجمالي/i];
  for (const line of lines.reverse()) {
    for (const pattern of totalsPatterns) {
      if (pattern.test(line)) {
        const priceMatch = line.match(/[\d,]+(?:\.\d{2})?/);
        if (priceMatch) {
          total = parseFloat(priceMatch[0].replace(/,/g, ''));
          break;
        }
      }
    }
    if (total) break;
  }

  // If no total found, use the largest price
  if (!total && priceMatches.length > 0) {
    const prices = priceMatches
      .map((m) => parseFloat(m[1].replace(/,/g, '')))
      .filter((p) => !isNaN(p));
    total = Math.max(...prices);
  }

  return {
    storeName,
    storeId,
    date,
    items,
    totalLBP: currency === 'LBP' ? total : null,
    totalUSD: currency === 'USD' ? total : null,
    currency,
    rawText: text,
    confidence,
  };
}
