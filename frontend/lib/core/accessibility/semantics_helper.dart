import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SemanticsHelper {
  /// Announces an assertive or polite message to screen readers (TalkBack / VoiceOver)
  static void announce(String message, {TextDirection textDirection = TextDirection.ltr}) {
    SemanticsService.announce(message, textDirection);
  }

  /// Formats an accessibility score announcement for screen readers
  static String formatRatingAnnouncement(double score, int totalReviews) {
    final formattedScore = score.toStringAsFixed(1);
    if (totalReviews == 0) {
      return 'Local sem avaliações registradas ainda';
    }
    return 'Nota de acessibilidade: $formattedScore de 5 estrelas, baseado em $totalReviews ${totalReviews == 1 ? "avaliação" : "avaliações"}';
  }

  /// Formats a criterion score for screen readers
  static String formatCriterionAnnouncement(String criterionTitle, int score) {
    return 'Critério $criterionTitle: $score de 5';
  }

  /// Formats a status badge for screen reader comprehension
  static String formatModerationStatus(String status) {
    switch (status) {
      case 'UNDER_REVIEW':
        return 'Alerta: Conteúdo sob análise comunitária devido a denúncias';
      case 'QUARANTINED':
        return 'Conteúdo em quarentena preventiva';
      case 'PUBLISHED':
        return 'Avaliação confirmada pela comunidade';
      default:
        return 'Status do conteúdo: $status';
    }
  }

  /// Checks if a review is outdated (> 12 months) and returns an accessible announcement
  static String? checkOutdatedReview(DateTime? lastReviewedAt) {
    if (lastReviewedAt == null) return null;
    final now = DateTime.now();
    final difference = now.difference(lastReviewedAt);
    if (difference.inDays > 365) {
      return 'Atenção: A última avaliação deste local ocorreu há mais de 12 meses. As condições de acessibilidade podem ter mudado.';
    }
    return null;
  }
}
