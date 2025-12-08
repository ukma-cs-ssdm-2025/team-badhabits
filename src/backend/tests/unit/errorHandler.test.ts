import { Request, Response, NextFunction } from "express";
import errorHandler from "../../../backend/middleware/errorHandler";

describe("errorHandler middleware", () => {
  let req: Partial<Request>;
  let res: Partial<Response>;
  let next: NextFunction;

  beforeEach(() => {
    req = {
      originalUrl: "/test",
      method: "GET",
    };

    res = {
      status: jest.fn().mockReturnThis() as any,
      json: jest.fn().mockReturnThis() as any,
      headersSent: false,
    };

    next = jest.fn();
  });

  // Helper to invoke middleware
  const call = (err: any) =>
    errorHandler(err, req as Request, res as Response, next);

  test("handles generic error (500)", () => {
    const err = new Error("Something broke");
    call(err);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          code: "INTERNAL_ERROR",
          message: "Something broke",
        }),
      })
    );
  });

  test("returns early when headers already sent", () => {
    (res.headersSent as boolean) = true;
    const err = new Error("Test");
    call(err);

    expect(next).toHaveBeenCalledWith(err);
  });

  test("handles ValidationError (Mongoose)", () => {
    const err = {
      name: "ValidationError",
      errors: {
        field1: { path: "email", message: "Invalid email" },
        field2: { path: "age", message: "Too young" },
      },
    };

    call(err);

    expect(res.status).toHaveBeenCalledWith(422);
    expect(res.json).toHaveBeenCalledWith({
      success: false,
      error: {
        code: "VALIDATION_ERROR",
        message: "Data validation error",
        details: [
          { field: "email", message: "Invalid email" },
          { field: "age", message: "Too young" },
        ],
      },
    });
  });

  test("handles JWT JsonWebTokenError", () => {
    const err = {
      name: "JsonWebTokenError",
      message: "jwt malformed",
    };

    call(err);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          message: "Invalid token",
        }),
      })
    );
  });

  test("handles TokenExpiredError", () => {
    const err = {
      name: "TokenExpiredError",
    };

    call(err);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          message: "Token expired",
        }),
      })
    );
  });

  test("handles CastError", () => {
    const err = { name: "CastError" };

    call(err);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          message: "Invalid ID format",
        }),
      })
    );
  });

  test("handles duplicate key error (11000) with field", () => {
    const err = {
      code: 11000,
      keyPattern: { email: 1 },
    };

    call(err);

    expect(res.status).toHaveBeenCalledWith(409);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          message: "Resource with this email already exists",
        }),
      })
    );
  });

  test("duplicate key error without field", () => {
    const err = { code: 11000 };

    call(err);

    expect(res.status).toHaveBeenCalledWith(409);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          message: "Resource already exists",
        }),
      })
    );
  });

  test("includes stack trace in development mode", () => {
    process.env.NODE_ENV = "development";

    const err = new Error("Boom!");
    err.stack = "STACK_TRACE";

    call(err);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        error: expect.objectContaining({
          stack: "STACK_TRACE",
        }),
      })
    );

    process.env.NODE_ENV = "test"; // cleanup
  });

  test("passes additional error.details", () => {
    const err = {
      message: "Invalid data",
      errors: { foo: "bar" },
    };

    call(err);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        error: expect.objectContaining({
          details: { foo: "bar" },
        }),
      })
    );
  });
});
