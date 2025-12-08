// firebase.d.ts
import { DocumentData } from "firebase-admin/firestore";

export const db: any;

export function getUserWorkoutSessions(
  userId: string,
  days?: number
): Promise<(DocumentData & { id: string })[]>;

export function getWorkoutsByDifficulty(
  difficulty: string,
  limit?: number
): Promise<(DocumentData & { id: string })[]>;

export function getUserProfile(
  userId: string
): Promise<(DocumentData & { id: string }) | null>;

export function calculateAverageRating(
  sessions: Array<{ difficulty_rating?: number | null }>
): number | null;
