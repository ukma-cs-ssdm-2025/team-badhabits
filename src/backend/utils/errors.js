/**
 * Base Application Error class
 * Extends Error with HTTP status codes for REST API
 */
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * 404 Not Found Error
 * Use when a requested resource doesn't exist
 */
class NotFoundError extends AppError {
  constructor(resource = 'Ресурс') {
    super(`${resource} не знайдено`, 404);
    this.code = 'NOT_FOUND';
  }
}

/**
 * 401 Unauthorized Error
 * Use when authentication is required but not provided or invalid
 */
class UnauthorizedError extends AppError {
  constructor(message = 'Необхідна автентифікація') {
    super(message, 401);
    this.code = 'UNAUTHORIZED';
  }
}

/**
 * 403 Forbidden Error
 * Use when user is authenticated but doesn't have permission
 */
class ForbiddenError extends AppError {
  constructor(message = 'Доступ заборонено') {
    super(message, 403);
    this.code = 'FORBIDDEN';
  }
}

/**
 * 400 Bad Request Error
 * Use for general client-side errors (invalid input)
 */
class BadRequestError extends AppError {
  constructor(message = 'Некоректний запит') {
    super(message, 400);
    this.code = 'BAD_REQUEST';
  }
}

/**
 * 409 Conflict Error
 * Use when request conflicts with current state (e.g., duplicate resource)
 */
class ConflictError extends AppError {
  constructor(message = 'Конфлікт ресурсу') {
    super(message, 409);
    this.code = 'CONFLICT';
  }
}

/**
 * 422 Validation Error
 * Use for validation failures with detailed error list
 */
class ValidationError extends AppError {
  constructor(message = 'Помилка валідації', errors = []) {
    super(message, 422);
    this.code = 'VALIDATION_ERROR';
    this.errors = errors;
  }
}

module.exports = {
  AppError,
  NotFoundError,
  UnauthorizedError,
  ForbiddenError,
  BadRequestError,
  ConflictError,
  ValidationError
};
