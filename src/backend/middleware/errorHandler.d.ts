import { Request, Response, NextFunction } from "express";

declare function errorHandler(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void;

export = errorHandler;
