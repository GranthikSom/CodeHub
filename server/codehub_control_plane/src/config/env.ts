import dotenv from 'dotenv';
dotenv.config();

const nodeEnv = process.env.NODE_ENV || 'development';
const databaseUrl = process.env.DATABASE_URL || 'postgresql://codehub:password@localhost:5432/codehub';

// Production Security Validation
if (nodeEnv === 'production') {
  if (databaseUrl.includes('localhost') || databaseUrl.includes('127.0.0.1')) {
    console.error('❌ CRITICAL SECURITY ERROR: DATABASE_URL cannot use "localhost" in production!');
    throw new Error('Production DATABASE_URL safety check failed: Cannot use localhost or 127.0.0.1 in production mode');
  }
  if (!process.env.JWT_ACCESS_SECRET || process.env.JWT_ACCESS_SECRET.includes('CHANGE_THIS')) {
    console.warn('⚠️ SECURITY WARNING: Production JWT_ACCESS_SECRET must be supplied via a Secrets Manager.');
  }
}

export const config = {
  nodeEnv,
  port: parseInt(process.env.PORT || '4000', 10),
  host: process.env.HOST || '0.0.0.0',
  appUrl: process.env.APP_URL || (nodeEnv === 'production' ? 'https://api.codehub.example' : 'http://localhost:4000'),
  clientUrl: process.env.CLIENT_URL || (nodeEnv === 'production' ? 'https://codehub.example' : 'http://localhost:3000'),
  databaseUrl,
  redisUrl: process.env.REDIS_URL || (nodeEnv === 'production' ? 'rediss://redis.production.internal:6379' : 'redis://localhost:6379'),
  jwtAccessSecret: process.env.JWT_ACCESS_SECRET || 'CHANGE_THIS_TO_A_LONG_RANDOM_SECRET',
  jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || 'CHANGE_THIS_TO_ANOTHER_LONG_RANDOM_SECRET',
  jwtAccessExpires: process.env.JWT_ACCESS_EXPIRES || '15m',
  jwtRefreshExpires: process.env.JWT_REFRESH_EXPIRES || '30d',
  socketPath: process.env.SOCKET_PATH || '/socket.io',
  corsOrigins: (process.env.CORS_ORIGINS || (nodeEnv === 'production' ? 'https://codehub.example' : 'http://localhost:3000,http://localhost:8080')).split(','),
  jwtSecret: process.env.JWT_ACCESS_SECRET || 'CHANGE_THIS_TO_A_LONG_RANDOM_SECRET',
};
