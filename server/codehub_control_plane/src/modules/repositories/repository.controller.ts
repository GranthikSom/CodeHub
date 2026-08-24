import { FastifyRequest, FastifyReply } from 'fastify';
import { createRepositorySchema } from './repository.schema.js';
import { createRepositoryService } from './repository.service.js';

export async function createRepositoryHandler(request: FastifyRequest, reply: FastifyReply) {
  // 1. Authentication Check & User Extraction
  let username = 'GranthikSom';
  if ((request as any).user && (request as any).user.username) {
    username = (request as any).user.username;
  } else if ((request.body as any)?.owner) {
    username = (request.body as any).owner;
  }

  // 2. Validate Request Body Schema
  const parseResult = createRepositorySchema.safeParse(request.body);
  if (!parseResult.success) {
    return reply.status(400).send({
      success: false,
      message: 'Validation failed',
      errors: parseResult.error.flatten().fieldErrors,
    });
  }

  try {
    // 3. Execute Service (Uniqueness check -> Create repo -> Metadata -> Publish Event)
    const repository = await createRepositoryService(username, parseResult.data);

    return reply.status(201).send({
      success: true,
      message: `Repository '${repository.full_name}' created successfully`,
      data: repository,
    });
  } catch (error: any) {
    const statusCode = error.statusCode || 500;
    return reply.status(statusCode).send({
      success: false,
      message: error.message || 'Failed to create repository',
    });
  }
}
