import prisma from "../prisma.js";
import { syncDailySummary } from "./dailySummary.service.js";

// Approximate calorie burn per step (adjustable)
const CALORIES_PER_STEP = 0.04;

export async function getDailySteps(userId: string, date?: string) {
  if (date) {
    const dateOnly = new Date(date);
    return prisma.dailyStep.findUnique({
      where: { userId_date: { userId, date: dateOnly } },
    });
  }

  return prisma.dailyStep.findMany({
    where: { userId },
    orderBy: { date: "desc" },
    take: 30, // last 30 days
  });
}

export async function upsertDailySteps(
  userId: string,
  steps: number,
  date?: string
) {
  const dateOnly = date ? new Date(date) : new Date(new Date().toISOString().split("T")[0]);

  // Get user weight to improve calorie estimation
  const user = await prisma.user.findUnique({ where: { id: userId } });
  const weightFactor = user?.weightKg ? user.weightKg / 70 : 1; // normalized to 70kg
  const caloriesBurned = Math.round(steps * CALORIES_PER_STEP * weightFactor * 100) / 100;

  const record = await prisma.dailyStep.upsert({
    where: { userId_date: { userId, date: dateOnly } },
    update: { steps, caloriesBurned },
    create: { userId, steps, caloriesBurned, date: dateOnly },
  });

  // Update daily summary with new calories burned
  await syncDailySummary(userId, dateOnly);

  return record;
}
