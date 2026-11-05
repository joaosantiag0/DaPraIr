import { z } from 'zod';

export const VisibilityEnum = z.enum(['PUBLIC', 'COMMUNITY', 'AUTHOR']);
export type Visibility = z.infer<typeof VisibilityEnum>;

export const TopicSortByEnum = z.enum(['recent', 'likes', 'comments']);
export type TopicSortBy = z.infer<typeof TopicSortByEnum>;

export const ContentReportReasonEnum = z.enum([
  'SPAM',
  'HARASSMENT',
  'HATE_SPEECH',
  'PRIVACY_VIOLATION',
  'INAPPROPRIATE_CONTENT',
  'OTHER',
]);

// Categories
export const createCategorySchema = z.object({
  name: z.string().min(2).max(100),
  slug: z.string().min(2).max(100),
  description: z.string().min(5),
  icon_name: z.string().min(1).max(50),
  display_order: z.coerce.number().optional().default(0),
  is_active: z.boolean().optional().default(true),
});

export const queryCategoriesSchema = z.object({
  is_active: z
    .preprocess((val) => (val === 'true' ? true : val === 'false' ? false : val), z.boolean())
    .optional(),
});

// Topics
export const createTopicSchema = z.object({
  category_id: z.string().uuid(),
  title: z.string().min(5).max(200),
  content: z.string().min(10),
  visibility: VisibilityEnum.default('PUBLIC'),
});

export const queryTopicsSchema = z.object({
  category_id: z.string().uuid().optional(),
  sort_by: TopicSortByEnum.optional().default('recent'),
  query: z.string().optional(),
  visibility: VisibilityEnum.optional(),
  limit: z.coerce.number().min(1).max(100).optional().default(20),
  offset: z.coerce.number().min(0).optional().default(0),
});

export const updateTopicSchema = z.object({
  title: z.string().min(5).max(200).optional(),
  content: z.string().min(10).optional(),
  visibility: VisibilityEnum.optional(),
});

// Comments
export const createCommentSchema = z.object({
  parent_id: z.string().uuid().nullable().optional(),
  content: z.string().min(1).max(5000),
  visibility: VisibilityEnum.optional().default('PUBLIC'),
});

export const queryCommentsSchema = z.object({
  limit: z.coerce.number().min(1).max(200).optional().default(50),
  offset: z.coerce.number().min(0).optional().default(0),
});

export const updateCommentSchema = z.object({
  content: z.string().min(1).max(5000).optional(),
  visibility: VisibilityEnum.optional(),
});

// Content Reports
export const reportForumContentSchema = z.object({
  target_type: z.enum(['FORUM_TOPIC', 'FORUM_COMMENT']),
  target_id: z.string().uuid(),
  reason: ContentReportReasonEnum,
  details: z.string().max(1000).optional(),
});
