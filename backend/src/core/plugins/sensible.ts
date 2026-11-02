import fastifyPlugin from 'fastify-plugin';
import fastifySensible from '@fastify/sensible';
import { FastifyInstance, FastifyError, FastifyRequest, FastifyReply } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../errors/app-error.js';

export const sensiblePlugin = fastifyPlugin(async (fastify: FastifyInstance) => {
  await fastify.register(fastifySensible);

  fastify.setErrorHandler((error: FastifyError | AppError | ZodError | Error, request: FastifyRequest, reply: FastifyReply) => {
    request.log.error(error);

    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        statusCode: error.statusCode,
        error: error.name,
        code: error.code,
        message: error.message,
        details: error.details,
      });
    }

    if (error instanceof ZodError) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        code: 'VALIDATION_ERROR',
        message: 'Invalid input parameters',
        details: error.format(),
      });
    }

    // Fastify schema validation error
    if ('validation' in error && error.validation) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        code: 'VALIDATION_ERROR',
        message: error.message,
        details: error.validation,
      });
    }

    const statusCode = 'statusCode' in error && typeof error.statusCode === 'number' ? error.statusCode : 500;
    return reply.status(statusCode).send({
      statusCode,
      error: 'Internal Server Error',
      message: statusCode === 500 ? 'An unexpected error occurred' : error.message,
    });
  });
});
