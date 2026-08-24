import { z } from 'zod';

export const createRepositorySchema = z.object({
  name: z
    .string()
    .min(1, 'Repository name is required')
    .max(100, 'Repository name cannot exceed 100 characters')
    .regex(/^[a-zA-Z0-9_.-]+$/, 'Repository name contains invalid characters'),
  description: z.string().max(500).optional(),
  visibility: z.enum(['public', 'private']).optional().default('public'),
  defaultBranch: z.string().optional().default('main'),
  default_branch: z.string().optional(),
});

export type CreateRepositoryInput = z.infer<typeof createRepositorySchema>;
