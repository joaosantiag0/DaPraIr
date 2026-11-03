import 'package:dio/dio.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final Dio dio;

  FeedRepositoryImpl(this.dio);

  static final List<HighlightedPlace> _fallbackPlaces = [
    const HighlightedPlace(
      id: 'place-pinacoteca',
      name: 'Pinacoteca de São Paulo',
      category: 'MUSEUM',
      address: 'Praça da Luz, 2 - Luz, São Paulo - SP',
      latitude: -23.5348,
      longitude: -46.6341,
      overallScore: 4.9,
      totalReviews: 42,
    ),
    const HighlightedPlace(
      id: 'place-ibirapuera',
      name: 'Parque Ibirapuera',
      category: 'PARK',
      address: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
      latitude: -23.5874,
      longitude: -46.6576,
      overallScore: 4.8,
      totalReviews: 128,
    ),
    const HighlightedPlace(
      id: 'place-sesc-pompeia',
      name: 'Sesc Pompeia',
      category: 'THEATER',
      address: 'Rua Clélia, 93 - Água Branca, São Paulo - SP',
      latitude: -23.5262,
      longitude: -46.6853,
      overallScore: 4.9,
      totalReviews: 56,
    ),
    const HighlightedPlace(
      id: 'place-museu-futebol',
      name: 'Museu do Futebol (Pacaembu)',
      category: 'MUSEUM',
      address: 'Praça Charles Miller, s/n - Pacaembu, São Paulo - SP',
      latitude: -23.5483,
      longitude: -46.6654,
      overallScore: 4.7,
      totalReviews: 38,
    ),
    const HighlightedPlace(
      id: 'place-terraco-italia',
      name: 'Restaurante Terraço Itália',
      category: 'RESTAURANT',
      address: 'Av. Ipiranga, 344 - 41º andar - Centro, São Paulo - SP',
      latitude: -23.5451,
      longitude: -46.6433,
      overallScore: 4.6,
      totalReviews: 19,
    ),
    const HighlightedPlace(
      id: 'place-livraria-vila',
      name: 'Livraria da Vila - Fradique',
      category: 'STORE',
      address: 'Rua Fradique Coutinho, 915 - Pinheiros, São Paulo - SP',
      latitude: -23.5602,
      longitude: -46.6891,
      overallScore: 4.5,
      totalReviews: 15,
    ),
  ];

  static final List<RecentFeedReview> _fallbackReviews = [
    RecentFeedReview(
      id: 'rev-pinacoteca-1',
      placeId: 'place-pinacoteca',
      placeName: 'Pinacoteca de São Paulo',
      placeAddress: 'Praça da Luz, 2 - Luz, São Paulo - SP',
      generalComment:
          'Experiência impecável! Entrada pela lateral totalmente nivelada, elevadores espaçosos para cadeira motorizada e banheiros adaptados excelentes com alarme sonoro.',
      averageScore: 5.0,
      status: 'PUBLISHED',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      authorName: 'Juliana Mendes',
      authorHandle: '@ju_mendes',
      mediaThumbnails: const [],
    ),
    RecentFeedReview(
      id: 'rev-ibira-1',
      placeId: 'place-ibirapuera',
      placeName: 'Parque Ibirapuera',
      placeAddress: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
      generalComment:
          'O parque é maravilhoso para passear. As pistas entre os portões 3 e 7 estão recapeadas e sem buracos. Os sanitários adaptados do Pavilhão das Culturas Brasileiras têm barras firmes.',
      averageScore: 4.8,
      status: 'PUBLISHED',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      authorName: 'Marcos Vinícius',
      authorHandle: '@marcos_v',
      mediaThumbnails: const [],
    ),
    RecentFeedReview(
      id: 'rev-sesc-1',
      placeId: 'place-sesc-pompeia',
      placeName: 'Sesc Pompeia',
      placeAddress: 'Rua Clélia, 93 - Água Branca, São Paulo - SP',
      generalComment:
          'Um dos melhores espaços culturais da cidade para cadeirantes. Rampas de concreto com inclinação ideal, mesas do restaurante na altura correta e equipe atenciosa.',
      averageScore: 5.0,
      status: 'PUBLISHED',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      authorName: 'Carla Albuquerque',
      authorHandle: '@carla_a',
      mediaThumbnails: const [],
    ),
    RecentFeedReview(
      id: 'rev-futebol-1',
      placeId: 'place-museu-futebol',
      placeName: 'Museu do Futebol (Pacaembu)',
      placeAddress: 'Praça Charles Miller, s/n - Pacaembu, São Paulo - SP',
      generalComment:
          'Muito bem adaptado! Elevador para todos os andares de exposição, piso tátil por todo o percurso e mesas de áudio interativas bem posicionadas para cadeirantes.',
      averageScore: 4.7,
      status: 'PUBLISHED',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      authorName: 'Roberto Fernandes',
      authorHandle: '@roberto_f',
      mediaThumbnails: const [],
    ),
    RecentFeedReview(
      id: 'rev-inclusao-1',
      placeId: 'place-inclusao',
      placeName: 'Museu da Inclusão',
      placeAddress: 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP',
      generalComment: 'Excelente rampa e guias atenciosos! Todo o espaço foi pensado com desenho universal desde a concepção.',
      averageScore: 5.0,
      status: 'UNDER_REVIEW',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      authorName: 'Carlos Silva',
      authorHandle: '@carlos_s',
      mediaThumbnails: const [],
    ),
  ];

  static final List<FeedEventSummary> _fallbackEvents = [
    FeedEventSummary(
      id: 'event-pinacoteca-visita',
      title: 'Visita Guiada Multissensorial na Pinacoteca',
      description: 'Visita mediada com audiodescrição, maquetes táteis das obras e percurso 100% nivelado.',
      startTime: DateTime.now().add(const Duration(days: 3)),
      endTime: DateTime.now().add(const Duration(days: 3, hours: 3)),
      locationName: 'Pinacoteca de São Paulo',
      address: 'Praça da Luz, 2 - Luz, São Paulo - SP',
      rsvpCount: 28,
      isAttending: false,
      organizerName: 'Educativo Pinacoteca',
    ),
    FeedEventSummary(
      id: 'event-ibira-piquenique',
      title: 'Passeio & Piquenique Inclusivo no Ibirapuera',
      description: 'Encontro comunitário de cadeirantes e pessoas com mobilidade reduzida para compartilhar dicas de acessibilidade urbana.',
      startTime: DateTime.now().add(const Duration(days: 6)),
      endTime: DateTime.now().add(const Duration(days: 6, hours: 4)),
      locationName: 'Parque Ibirapuera (Portão 10)',
      address: 'Av. Pedro Álvares Cabral - Moema, São Paulo - SP',
      rsvpCount: 45,
      isAttending: false,
      organizerName: 'Marina Cordeiro',
    ),
    FeedEventSummary(
      id: 'event-sarau-libras',
      title: 'Sarau com Acessibilidade e Poesia Viva',
      description: 'Música e poesia com audiodescrição ao vivo e tradução simultânea em Língua Brasileira de Sinais (Libras).',
      startTime: DateTime.now().add(const Duration(days: 10)),
      endTime: DateTime.now().add(const Duration(days: 10, hours: 3)),
      locationName: 'Centro Cultural São Paulo (CCSP)',
      address: 'Rua Vergueiro, 1000 - Paraíso, São Paulo - SP',
      rsvpCount: 34,
      isAttending: false,
      organizerName: 'Coletivo Acesso Livre',
    ),
  ];

  static final List<AccessibilityTip> _fallbackTips = [
    const AccessibilityTip(
      id: 'tip-1',
      title: 'Inclinação de Rampas (ABNT NBR 9050)',
      content: 'Uma rampa ideal para cadeiras de rodas deve ter inclinação entre 5% e 8,33%. Rampas acima de 10% oferecem alto risco de tombamento sem auxílio.',
      category: 'MOBILITY',
    ),
    const AccessibilityTip(
      id: 'tip-2',
      title: 'Portas e Vãos Livres',
      content: 'O vão livre mínimo recomendável para passagem confortável de cadeira de rodas é de 80 cm. Meça sempre com a porta aberta a 90 graus.',
      category: 'MOBILITY',
    ),
    const AccessibilityTip(
      id: 'tip-3',
      title: 'Sinalização Visual e Tátil',
      content: 'Piso tátil direcional orienta o trajeto contínuo, enquanto o piso tátil de alerta indica mudanças de direção, escadas e obstáculos suspensos.',
      category: 'VISION',
    ),
    const AccessibilityTip(
      id: 'tip-4',
      title: 'Espaços Amigáveis para Neurodivergentes',
      content: 'Locais com menor poluição sonora, iluminação indireta regulável e salas de descompressão facilitam a permanência de pessoas no espectro autista.',
      category: 'NEURODIVERSITY',
    ),
    const AccessibilityTip(
      id: 'tip-5',
      title: 'Sanitários Acessíveis e Barras de Apoio',
      content: 'O banheiro adaptado deve possuir barras de apoio horizontais fixas e articuladas, raio de giro de 360° (1,50 m) e porta que abra para fora ou seja de correr com trinco ergonômico.',
      category: 'MOBILITY',
    ),
    const AccessibilityTip(
      id: 'tip-6',
      title: 'Vagas de Estacionamento Reservadas (Lei 13.146)',
      content: 'O Estatuto da Pessoa com Deficiência assegura 2% das vagas em estacionamentos públicos e privados, com faixa de circulação adicional de 1,20 m para desembarque de cadeira de rodas.',
      category: 'MOBILITY',
    ),
  ];

  @override
  Future<FeedData> getFeed({double? latitude, double? longitude, int limit = 10}) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (latitude != null) queryParams['latitude'] = latitude;
    if (longitude != null) queryParams['longitude'] = longitude;

    try {
      final response = await dio.get('/api/v1/feed', queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;

      var placesList = (data['highlightedPlaces'] as List<dynamic>? ?? []).map((json) {
        return HighlightedPlace(
          id: json['id'] as String,
          name: json['name'] as String,
          category: json['category'] as String,
          address: json['address'] as String,
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
          overallScore: (json['overallScore'] as num).toDouble(),
          totalReviews: json['totalReviews'] as int? ?? 0,
          coverImageUrl: json['coverImageUrl'] as String?,
        );
      }).toList();

      var reviewsList = (data['recentReviews'] as List<dynamic>? ?? []).map((json) {
        final author = json['author'] as Map<String, dynamic>? ?? {};
        final media = (json['media'] as List<dynamic>? ?? [])
            .map((m) => (m['thumbnailUrl'] ?? m['mediaUrl']) as String)
            .toList();

        return RecentFeedReview(
          id: json['id'] as String,
          placeId: json['placeId'] as String,
          placeName: json['placeName'] as String,
          placeAddress: json['placeAddress'] as String,
          generalComment: json['generalComment'] as String?,
          averageScore: (json['averageScore'] as num).toDouble(),
          status: json['status'] as String? ?? 'PUBLISHED',
          createdAt: DateTime.parse(json['createdAt'] as String),
          authorName: author['name'] as String? ?? 'Usuário',
          authorHandle: author['handle'] as String? ?? '@usuario',
          authorAvatarUrl: author['avatarUrl'] as String?,
          mediaThumbnails: media,
        );
      }).toList();

      var eventsList = (data['upcomingEvents'] as List<dynamic>? ?? []).map((json) {
        return FeedEventSummary(
          id: json['id'] as String,
          title: json['title'] as String,
          description: json['description'] as String,
          startTime: DateTime.parse(json['startTime'] as String),
          endTime: DateTime.parse(json['endTime'] as String),
          locationName: json['locationName'] as String,
          address: json['address'] as String,
          rsvpCount: json['rsvpCount'] as int? ?? 0,
          isAttending: json['isAttending'] as bool? ?? false,
          organizerName: json['organizerName'] as String? ?? 'Comunidade',
        );
      }).toList();

      var tipsList = (data['accessibilityTips'] as List<dynamic>? ?? []).map((json) {
        return AccessibilityTip(
          id: json['id'] as String,
          title: json['title'] as String,
          content: json['content'] as String,
          category: json['category'] as String,
        );
      }).toList();

      if (placesList.isEmpty) placesList = _fallbackPlaces;
      if (reviewsList.isEmpty) reviewsList = _fallbackReviews;
      if (eventsList.isEmpty) eventsList = _fallbackEvents;
      if (tipsList.isEmpty) tipsList = _fallbackTips;

      return FeedData(
        highlightedPlaces: placesList,
        recentReviews: reviewsList,
        upcomingEvents: eventsList,
        accessibilityTips: tipsList,
      );
    } catch (_) {
      // If network fails or offline, return rich curated community defaults
      return FeedData(
        highlightedPlaces: _fallbackPlaces,
        recentReviews: _fallbackReviews,
        upcomingEvents: _fallbackEvents,
        accessibilityTips: _fallbackTips,
      );
    }
  }
}
