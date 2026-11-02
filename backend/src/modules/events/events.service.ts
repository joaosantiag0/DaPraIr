import { prisma } from '../../core/database/prisma.js';
import { BadRequestError, NotFoundError } from '../../core/errors/app-error.js';

export interface CreateEventDTO {
  creatorId: string;
  placeId?: string;
  title: string;
  description: string;
  startTime: Date;
  endTime: Date;
  locationName: string;
  address: string;
  latitude?: number;
  longitude?: number;
  accessibilityChecklist: Record<string, boolean>;
  maxAttendees?: number;
}

export class EventsService {
  /**
   * Create event with MANDATORY declared accessibility checklist (FR-017)
   */
  async createEvent(data: CreateEventDTO) {
    const {
      creatorId,
      placeId,
      title,
      description,
      startTime,
      endTime,
      locationName,
      address,
      latitude,
      longitude,
      accessibilityChecklist,
      maxAttendees,
    } = data;

    // FR-017: Mandatory accessibility conditions checklist
    if (!accessibilityChecklist || Object.keys(accessibilityChecklist).length === 0) {
      throw new BadRequestError(
        'A declaração de checklist de condições de acessibilidade física do local é obrigatória para publicar um evento'
      );
    }

    if (endTime <= startTime) {
      throw new BadRequestError('O horário de término do evento deve ser posterior ao início');
    }

    const event = await prisma.event.create({
      data: {
        creator_id: creatorId,
        place_id: placeId,
        title,
        description,
        start_time: startTime,
        end_time: endTime,
        location_name: locationName,
        address,
        latitude,
        longitude,
        accessibility_checklist: accessibilityChecklist,
        max_attendees: maxAttendees,
        status: 'SCHEDULED',
      },
      include: {
        user: { select: { id: true, name: true, handle: true, avatar_url: true } },
      },
    });

    return this.mapEvent(event, 0, false);
  }

  /**
   * List upcoming inclusive events with optional accessibility filter
   */
  async listEvents(params: {
    startDate?: Date;
    endDate?: Date;
    accessibilityFeature?: string;
    userId?: string;
    limit?: number;
    offset?: number;
  }) {
    const { startDate = new Date(), accessibilityFeature, userId, limit = 20, offset = 0 } = params;

    const events = await prisma.event.findMany({
      where: {
        status: 'SCHEDULED',
        start_time: { gte: startDate },
      },
      include: {
        user: { select: { id: true, name: true, handle: true, avatar_url: true } },
        rsvps: true,
      },
      orderBy: { start_time: 'asc' },
      take: limit,
      skip: offset,
    });

    let filtered = events;
    if (accessibilityFeature) {
      filtered = events.filter((e) => {
        const checklist = e.accessibility_checklist as Record<string, boolean>;
        return checklist && checklist[accessibilityFeature] === true;
      });
    }

    return filtered.map((e) => {
      const isAttending = userId ? e.rsvps.some((r) => r.user_id === userId && r.status === 'CONFIRMED') : false;
      return this.mapEvent(e, e.rsvps.length, isAttending);
    });
  }

  /**
   * Register or toggle RSVP for an event
   */
  async registerRSVP(eventId: string, userId: string, status: 'CONFIRMED' | 'DECLINED' = 'CONFIRMED') {
    const event = await prisma.event.findUnique({
      where: { id: eventId },
      include: { rsvps: true },
    });

    if (!event) {
      throw new NotFoundError('Evento não encontrado');
    }

    if (event.max_attendees && event.rsvps.length >= event.max_attendees && status === 'CONFIRMED') {
      throw new BadRequestError('Evento com lotação esgotada');
    }

    const rsvp = await prisma.eventRSVP.upsert({
      where: {
        event_id_user_id: { event_id: eventId, user_id: userId },
      },
      update: { status },
      create: { event_id: eventId, user_id: userId, status },
    });

    return {
      eventId: rsvp.event_id,
      userId: rsvp.user_id,
      status: rsvp.status,
    };
  }

  private mapEvent(e: any, rsvpCount: number, isAttending: boolean) {
    return {
      id: e.id,
      title: e.title,
      description: e.description,
      startTime: e.start_time,
      endTime: e.end_time,
      locationName: e.location_name,
      address: e.address,
      latitude: e.latitude,
      longitude: e.longitude,
      accessibilityChecklist: e.accessibility_checklist,
      maxAttendees: e.max_attendees,
      status: e.status,
      rsvpCount,
      isAttending,
      organizer: e.user,
    };
  }
}

export const eventsService = new EventsService();
