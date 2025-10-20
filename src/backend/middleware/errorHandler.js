/**
 * Global Error Handler Middleware
 * Handles all errors thrown in routes and returns standardized JSON responses
 */
const errorHandler = (err, req, res, next) => {
  // Log error details for debugging
  console.error('Error:', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    url: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });

  // If headers already sent, delegate to Express default error handler
  if (res.headersSent) {
    return next(err);
  }

  // Determine status code
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Внутрішня помилка сервера';

  // Handle specific error types

  // Mongoose ValidationError
  if (err.name === 'ValidationError') {
    statusCode = 422;
    const errors = Object.values(err.errors).map(e => ({
      field: e.path,
      message: e.message
    }));
    return res.status(statusCode).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Помилка валідації даних',
        details: errors
      }
    });
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Невалідний токен';
  }

  if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Токен прострочений';
  }

  // MongoDB CastError (invalid ID format)
  if (err.name === 'CastError') {
    statusCode = 400;
    message = 'Невалідний формат ID';
  }

  // MongoDB duplicate key error
  if (err.code === 11000) {
    statusCode = 409;
    const field = Object.keys(err.keyPattern || {})[0];
    message = field ? `Ресурс з таким ${field} вже існує` : 'Ресурс вже існує';
  }

  // Build error response
  const errorResponse = {
    success: false,
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: message
    }
  };

  // Add stack trace only in development
  if (process.env.NODE_ENV === 'development') {
    errorResponse.error.stack = err.stack;
  }

  // Add additional error details if present
  if (err.errors) {
    errorResponse.error.details = err.errors;
  }

  res.status(statusCode).json(errorResponse);
};

module.exports = errorHandler;
