import { prisma } from '../../core/database/prisma.js';
import { AwardPointsInput, UpdateGamificationPreferencesInput } from './gamification.schemas.js';

export class GamificationService {
  /**
   * Retrieves or initializes a user's gamification profile.
   */
  async getOrCreateProfile(userId: string) {
    let profile = await prisma.userGamificationProfile.findUnique({
      where: { user_id: userId },
      include: { level: true },
    });

    if (!profile) {
      // Find base level
      const baseLevel = await prisma.gamificationLevel.findFirst({
        orderBy: { level_order: 'asc' },
      });

      profile = await prisma.userGamificationProfile.create({
        data: {
          user_id: userId,
          points_total: 0,
          points_current: 0,
          current_level_id: baseLevel ? baseLevel.id : 'EXPLORER',
          is_ranking_visible: true,
          use_anonymous_nickname: false,
        },
        include: { level: true },
      });
    }

    return profile;
  }

  /**
   * Calculates the appropriate level for a given points total.
   */
  async calculateLevelForPoints(pointsTotal: number) {
    const levels = await prisma.gamificationLevel.findMany({
      orderBy: { min_points: 'desc' },
    });

    for (const level of levels) {
      if (pointsTotal >= level.min_points) {
        return level;
      }
    }

    return levels[levels.length - 1] || null;
  }

  /**
   * Checks daily point caps for anti-abuse safeguards.
   */
  async checkDailyCap(userId: string, actionType: string): Promise<boolean> {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const isReview = ['AVALIACAO_LOCAL', 'BONUS_FOTO', 'BONUS_UTILIDADE'].includes(actionType);
    const isForum = ['TOPICO_FORUM', 'RESPOSTA_UTIL'].includes(actionType);

    const filterActions = isReview
      ? ['AVALIACAO_LOCAL', 'BONUS_FOTO', 'BONUS_UTILIDADE']
      : isForum
      ? ['TOPICO_FORUM', 'RESPOSTA_UTIL']
      : [actionType];

    const aggregate = await prisma.gamificationTransaction.aggregate({
      where: {
        user_id: userId,
        action_type: { in: filterActions },
        created_at: { gte: startOfDay },
        points: { gt: 0 },
      },
      _sum: { points: true },
    });

    const currentPointsToday = aggregate._sum.points || 0;
    const maxCap = isReview ? 150 : isForum ? 50 : 200;

    return currentPointsToday < maxCap;
  }

  /**
   * Awards points atomically and idempotently.
   */
  async awardPoints(input: AwardPointsInput) {
    const { userId, actionType, points, sourceId, sourceType, description } = input;

    // Idempotency check: if already awarded for this specific source, return existing
    if (sourceId) {
      const existing = await prisma.gamificationTransaction.findUnique({
        where: {
          user_id_action_type_source_id: {
            user_id: userId,
            action_type: actionType,
            source_id: sourceId,
          },
        },
      });
      if (existing) {
        return existing;
      }
    }

    // Verify daily cap
    const canAward = await this.checkDailyCap(userId, actionType);
    if (!canAward) {
      return null;
    }

    return prisma.$transaction(async (tx) => {
      // 1. Record transaction
      const transaction = await tx.gamificationTransaction.create({
        data: {
          user_id: userId,
          action_type: actionType,
          points,
          source_id: sourceId,
          source_type: sourceType,
          description,
        },
      });

      // 2. Fetch or create profile
      let profile = await tx.userGamificationProfile.findUnique({
        where: { user_id: userId },
      });

      const newTotal = (profile ? profile.points_total : 0) + points;
      const newCurrent = (profile ? profile.points_current : 0) + points;

      // 3. Recalculate level
      const levels = await tx.gamificationLevel.findMany({
        orderBy: { min_points: 'desc' },
      });
      let targetLevelId = 'EXPLORER';
      for (const lvl of levels) {
        if (newTotal >= lvl.min_points) {
          targetLevelId = lvl.id;
          break;
        }
      }

      await tx.userGamificationProfile.upsert({
        where: { user_id: userId },
        update: {
          points_total: newTotal,
          points_current: newCurrent,
          current_level_id: targetLevelId,
        },
        create: {
          user_id: userId,
          points_total: newTotal,
          points_current: newCurrent,
          current_level_id: targetLevelId,
          is_ranking_visible: true,
          use_anonymous_nickname: false,
        },
      });

      return transaction;
    });
  }

  /**
   * Rolls back points previously awarded (e.g., content removal or report).
   */
  async rollbackPoints(userId: string, sourceId: string, reason: string) {
    const originalTransactions = await prisma.gamificationTransaction.findMany({
      where: {
        user_id: userId,
        source_id: sourceId,
        points: { gt: 0 },
      },
    });

    if (originalTransactions.length === 0) return;

    const totalToRollback = originalTransactions.reduce((acc, t) => acc + t.points, 0);

    return prisma.$transaction(async (tx) => {
      await tx.gamificationTransaction.create({
        data: {
          user_id: userId,
          action_type: 'ESTORNO',
          points: -totalToRollback,
          source_id: sourceId,
          description: `Estorno: ${reason}`,
        },
      });

      const profile = await tx.userGamificationProfile.findUnique({
        where: { user_id: userId },
      });

      if (profile) {
        const newTotal = Math.max(0, profile.points_total - totalToRollback);
        const newCurrent = Math.max(0, profile.points_current - totalToRollback);

        const levels = await tx.gamificationLevel.findMany({
          orderBy: { min_points: 'desc' },
        });
        let targetLevelId = 'EXPLORER';
        for (const lvl of levels) {
          if (newTotal >= lvl.min_points) {
            targetLevelId = lvl.id;
            break;
          }
        }

        await tx.userGamificationProfile.update({
          where: { user_id: userId },
          data: {
            points_total: newTotal,
            points_current: newCurrent,
            current_level_id: targetLevelId,
          },
        });
      }
    });
  }

  /**
   * Retrieves full profile with level information and next level calculations.
   */
  async getUserProfile(userId: string) {
    const profile = await this.getOrCreateProfile(userId);

    const levels = await prisma.gamificationLevel.findMany({
      orderBy: { min_points: 'asc' },
    });

    const currentLevel = profile.level;
    const nextLevel = levels.find((l) => l.level_order === currentLevel.level_order + 1) || null;
    const pointsToNextLevel = nextLevel ? Math.max(0, nextLevel.min_points - profile.points_total) : 0;

    return {
      points_total: profile.points_total,
      points_current: profile.points_current,
      current_level: currentLevel,
      next_level: nextLevel,
      points_to_next_level: pointsToNextLevel,
      is_ranking_visible: profile.is_ranking_visible,
      use_anonymous_nickname: profile.use_anonymous_nickname,
      custom_nickname: profile.custom_nickname,
    };
  }

  /**
   * Retrieves paginated transactions for a user.
   */
  async getUserTransactions(userId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [transactions, total] = await Promise.all([
      prisma.gamificationTransaction.findMany({
        where: { user_id: userId },
        orderBy: { created_at: 'desc' },
        skip,
        take: limit,
      }),
      prisma.gamificationTransaction.count({ where: { user_id: userId } }),
    ]);

    return {
      transactions,
      total,
      page,
      limit,
    };
  }

  /**
   * Updates privacy preferences (LGPD opt-out / anonymity).
   */
  async updatePrivacyPreferences(userId: string, input: UpdateGamificationPreferencesInput) {
    await this.getOrCreateProfile(userId);

    const updated = await prisma.userGamificationProfile.update({
      where: { user_id: userId },
      data: {
        ...(input.is_ranking_visible !== undefined && { is_ranking_visible: input.is_ranking_visible }),
        ...(input.use_anonymous_nickname !== undefined && { use_anonymous_nickname: input.use_anonymous_nickname }),
        ...(input.custom_nickname !== undefined && { custom_nickname: input.custom_nickname }),
      },
      include: { level: true },
    });

    return this.getUserProfile(userId);
  }

  /**
   * Retrieves levels catalog.
   */
  async getLevels() {
    return prisma.gamificationLevel.findMany({
      orderBy: { level_order: 'asc' },
    });
  }

  /**
   * Leaderboard aggregation query by temporal period (weekly, monthly, all_time).
   */
  async getLeaderboard(period = 'monthly', page = 1, limit = 20, currentUserId?: string) {
    const skip = (page - 1) * limit;

    let startDate: Date | null = null;
    const now = new Date();

    if (period === 'weekly') {
      const day = now.getDay();
      startDate = new Date(now);
      startDate.setDate(now.getDate() - day);
      startDate.setHours(0, 0, 0, 0);
    } else if (period === 'monthly') {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0);
    }

    type LeaderboardRow = {
      user_id: string;
      name: string;
      handle: string;
      avatar_url: string | null;
      level_name: string;
      level_id: string;
      badge_icon: string | null;
      points: number;
      is_ranking_visible: boolean;
      use_anonymous_nickname: boolean;
      custom_nickname: string | null;
    };

    let rows: LeaderboardRow[] = [];
    let totalParticipants = 0;

    if (period === 'all_time') {
      const profiles = await prisma.userGamificationProfile.findMany({
        where: {
          is_ranking_visible: true,
          user: { status: 'ACTIVE' },
        },
        include: {
          user: true,
          level: true,
        },
        orderBy: { points_total: 'desc' },
        skip,
        take: limit,
      });

      totalParticipants = await prisma.userGamificationProfile.count({
        where: {
          is_ranking_visible: true,
          user: { status: 'ACTIVE' },
        },
      });

      rows = profiles.map((p) => ({
        user_id: p.user_id,
        name: p.user.name,
        handle: p.user.handle,
        avatar_url: p.user.avatar_url,
        level_name: p.level.name,
        level_id: p.level.id,
        badge_icon: p.level.badge_icon_url,
        points: p.points_total,
        is_ranking_visible: p.is_ranking_visible,
        use_anonymous_nickname: p.use_anonymous_nickname,
        custom_nickname: p.custom_nickname,
      }));
    } else {
      // Aggregation for weekly / monthly from transactions
      const periodTransactions = await prisma.gamificationTransaction.groupBy({
        by: ['user_id'],
        where: {
          created_at: { gte: startDate! },
          user: {
            status: 'ACTIVE',
            gamification_profile: { is_ranking_visible: true },
          },
        },
        _sum: { points: true },
        orderBy: { _sum: { points: 'desc' } },
        skip,
        take: limit,
      });

      const totalAgg = await prisma.gamificationTransaction.groupBy({
        by: ['user_id'],
        where: {
          created_at: { gte: startDate! },
          user: {
            status: 'ACTIVE',
            gamification_profile: { is_ranking_visible: true },
          },
        },
      });
      totalParticipants = totalAgg.length;

      const userIds = periodTransactions.map((pt) => pt.user_id);
      const profiles = await prisma.userGamificationProfile.findMany({
        where: { user_id: { in: userIds } },
        include: { user: true, level: true },
      });

      const profileMap = new Map(profiles.map((p) => [p.user_id, p]));

      rows = periodTransactions.map((pt) => {
        const p = profileMap.get(pt.user_id);
        return {
          user_id: pt.user_id,
          name: p?.user.name ?? 'Usuário',
          handle: p?.user.handle ?? 'usuario',
          avatar_url: p?.user.avatar_url ?? null,
          level_name: p?.level.name ?? 'Iniciante',
          level_id: p?.level.id ?? 'EXPLORER',
          badge_icon: p?.level.badge_icon_url ?? null,
          points: pt._sum.points ?? 0,
          is_ranking_visible: p?.is_ranking_visible ?? true,
          use_anonymous_nickname: p?.use_anonymous_nickname ?? false,
          custom_nickname: p?.custom_nickname ?? null,
        };
      });
    }

    const leaderboard = rows.map((r, index) => {
      const displayName = r.use_anonymous_nickname
        ? r.custom_nickname || `Membro Anônimo #${r.user_id.slice(0, 4)}`
        : r.name;

      return {
        rank: skip + index + 1,
        user_id: r.user_id,
        display_name: displayName,
        avatar_url: r.use_anonymous_nickname ? null : r.avatar_url,
        points: r.points,
        level_name: r.level_name,
        level_id: r.level_id,
        badge_icon: r.badge_icon,
      };
    });

    let userRankInfo: { rank: number; points: number; next_rank_points_diff: number } | null = null;
    if (currentUserId) {
      const userProfile = await prisma.userGamificationProfile.findUnique({
        where: { user_id: currentUserId },
      });

      if (userProfile && userProfile.is_ranking_visible) {
        // Find user placement
        const foundInPage = leaderboard.find((l) => l.user_id === currentUserId);
        if (foundInPage) {
          userRankInfo = {
            rank: foundInPage.rank,
            points: foundInPage.points,
            next_rank_points_diff:
              foundInPage.rank > 1 && leaderboard[foundInPage.rank - 2]
                ? Math.max(0, leaderboard[foundInPage.rank - 2].points - foundInPage.points)
                : 0,
          };
        }
      }
    }

    return {
      period,
      total_participants: totalParticipants,
      user_rank: userRankInfo,
      leaderboard,
    };
  }
}

export const gamificationService = new GamificationService();
