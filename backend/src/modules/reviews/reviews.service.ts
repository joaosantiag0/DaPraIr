import { prisma } from '../../core/database/prisma.js';
import { NotFoundError, BadRequestError } from '../../core/errors/app-error.js';
import { gamificationService } from '../gamification/gamification.service.js';

export interface RatingInput {
  criterionCode: string;
  score: number;
  notes?: string | null;
}

export interface CreateReviewDTO {
  placeId: string;
  userId: string;
  generalComment?: string | null;
  ratings: RatingInput[];
  mediaIds?: string[] | null;
}

export class ReviewsService {
  /**
   * Submit multicriteria review and update place aggregates
   */
  async createReview(data: CreateReviewDTO) {
    const { placeId, userId, generalComment, ratings } = data;
    const rawMediaIds = data.mediaIds ?? [];
    const mediaIds = Array.isArray(rawMediaIds) ? rawMediaIds.filter(Boolean) : [];
    const sanitizedComment = generalComment && generalComment.trim().length > 0 ? generalComment.trim() : null;

    if (!ratings || ratings.length === 0) {
      throw new BadRequestError('É obrigatório avaliar ao menos um critério de acessibilidade');
    }

    // Check place exists
    const place = await prisma.place.findUnique({ where: { id: placeId } });
    if (!place) {
      throw new NotFoundError('Local não encontrado');
    }

    // Resolve criteria
    const criteriaCodes = ratings.map((r) => r.criterionCode);
    const criteria = await prisma.accessibilityCriterion.findMany({
      where: { code: { in: criteriaCodes }, is_active: true },
    });

    if (criteria.length !== ratings.length) {
      throw new BadRequestError('Um ou mais códigos de critério são inválidos');
    }

    const criteriaMap = new Map(criteria.map((c) => [c.code, c]));

    // Calculate average score
    let totalScore = 0;
    for (const r of ratings) {
      if (r.score < 1 || r.score > 5) {
        throw new BadRequestError('A nota de cada critério deve estar entre 1 e 5');
      }
      totalScore += r.score;
    }
    const reviewAverage = Number((totalScore / ratings.length).toFixed(2));

    // Execute in transaction
    const review = await prisma.$transaction(async (tx) => {
      // Create review
      const newReview = await tx.placeReview.create({
        data: {
          place_id: placeId,
          user_id: userId,
          general_comment: sanitizedComment,
          average_score: reviewAverage,
          status: 'PUBLISHED',
        },
      });

      // Create ratings
      for (const r of ratings) {
        const criterion = criteriaMap.get(r.criterionCode)!;
        await tx.placeReviewRating.create({
          data: {
            review_id: newReview.id,
            criterion_id: criterion.id,
            score: r.score,
            notes: r.notes,
          },
        });
      }

      // Link media if provided
      if (mediaIds.length > 0) {
        await tx.placeMedia.updateMany({
          where: { id: { in: mediaIds }, user_id: userId },
          data: { review_id: newReview.id, place_id: placeId },
        });
      }

      // Recalculate place overall score and total reviews
      const placeReviews = await tx.placeReview.findMany({
        where: {
          place_id: placeId,
          status: { in: ['PUBLISHED', 'UNDER_REVIEW'] },
        },
        select: { average_score: true },
      });

      const totalReviewsCount = placeReviews.length;
      const sumScores = placeReviews.reduce((sum, rev) => sum + Number(rev.average_score), 0);
      const newOverallScore = totalReviewsCount > 0 ? Number((sumScores / totalReviewsCount).toFixed(2)) : 0;

      await tx.place.update({
        where: { id: placeId },
        data: {
          overall_score: newOverallScore,
          total_reviews: totalReviewsCount,
          last_reviewed_at: new Date(),
        },
      });

      return newReview;
    });

    // Award gamification points asynchronously / non-blocking
    try {
      // Base review points (+15)
      await gamificationService.awardPoints({
        userId,
        actionType: 'AVALIACAO_LOCAL',
        points: 15,
        sourceId: review.id,
        sourceType: 'REVIEW',
        description: `Avaliação de acessibilidade: ${place.name}`,
      });

      // Bonus photo points (+10 per photo, up to 3 photos / max 30)
      if (mediaIds.length > 0) {
        const photoBonusCount = Math.min(mediaIds.length, 3);
        for (let i = 0; i < photoBonusCount; i++) {
          await gamificationService.awardPoints({
            userId,
            actionType: 'BONUS_FOTO',
            points: 10,
            sourceId: mediaIds[i],
            sourceType: 'MEDIA',
            description: `Foto comprobatória de acessibilidade em ${place.name}`,
          });
        }
      }
    } catch (err) {
      // Gamification failure should not break review creation
      console.error('Failed to award gamification points for review:', err);
    }

    return this.getReviewById(review.id);
  }

  /**
   * Get single review with ratings and media
   */
  async getReviewById(reviewId: string) {
    const review = await prisma.placeReview.findUnique({
      where: { id: reviewId },
      include: {
        user: true,
        ratings: {
          include: { criterion: true },
        },
        media: true,
      },
    });

    if (!review) {
      throw new NotFoundError('Avaliação não encontrada');
    }

    return {
      id: review.id,
      placeId: review.place_id,
      generalComment: review.general_comment,
      averageScore: Number(review.average_score),
      reportCount: review.report_count,
      status: review.status,
      createdAt: review.created_at,
      author: review.user.is_anonymous
        ? { id: 'anonymous', name: 'Usuário DáPraIr?', handle: '@anonimo', avatarUrl: null }
        : {
            id: review.user.id,
            name: review.user.name,
            handle: review.user.handle.startsWith('@') ? review.user.handle : `@${review.user.handle}`,
            avatarUrl: review.user.avatar_url,
          },
      ratings: review.ratings.map((r) => ({
        criterionCode: r.criterion.code,
        criterionTitle: r.criterion.title,
        score: r.score,
        notes: r.notes,
      })),
      media: review.media.map((m) => ({
        id: m.id,
        mediaUrl: m.media_url,
        thumbnailUrl: m.thumbnail_url,
        altText: m.alt_text,
      })),
    };
  }

  /**
   * List reviews for a place (excludes quarantined and removed)
   */
  async listReviewsForPlace(placeId: string, limit = 10, offset = 0) {
    const [reviews, total] = await Promise.all([
      prisma.placeReview.findMany({
        where: {
          place_id: placeId,
          status: { in: ['PUBLISHED', 'UNDER_REVIEW'] }, // Quarantined auto-hidden
        },
        include: {
          user: true,
          ratings: {
            include: { criterion: true },
          },
          media: {
            where: { status: { in: ['ACTIVE', 'UNDER_REVIEW'] } },
          },
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset,
      }),
      prisma.placeReview.count({
        where: {
          place_id: placeId,
          status: { in: ['PUBLISHED', 'UNDER_REVIEW'] },
        },
      }),
    ]);

    const items = reviews.map((review) => ({
      id: review.id,
      placeId: review.place_id,
      generalComment: review.general_comment,
      averageScore: Number(review.average_score),
      reportCount: review.report_count,
      status: review.status, // Can be PUBLISHED or UNDER_REVIEW (with warning badge)
      createdAt: review.created_at,
      author: review.user.is_anonymous
        ? { id: 'anonymous', name: 'Usuário DáPraIr?', handle: '@anonimo', avatarUrl: null }
        : {
            id: review.user.id,
            name: review.user.name,
            handle: review.user.handle.startsWith('@') ? review.user.handle : `@${review.user.handle}`,
            avatarUrl: review.user.avatar_url,
          },
      ratings: review.ratings.map((r) => ({
        criterionCode: r.criterion.code,
        criterionTitle: r.criterion.title,
        score: r.score,
        notes: r.notes,
      })),
      media: review.media.map((m) => ({
        id: m.id,
        mediaUrl: m.media_url,
        thumbnailUrl: m.thumbnail_url,
        altText: m.alt_text,
      })),
    }));

    return { total, items };
  }
}

export const reviewsService = new ReviewsService();
