import prisma from "../prisma.js";
import { syncDailySummary } from "./dailySummary.service.js";

export async function getUserExercises(
  userId: string,
  params: { date?: string }
) {
  const where: any = { userId };

  if (params.date) {
    where.exerciseDate = new Date(params.date);
  }

  return prisma.exercise.findMany({
    where,
    orderBy: { createdAt: "desc" },
  });
}

export async function createExercise(
  userId: string,
  data: {
    name: string;
    durationMinutes?: number;
    caloriesBurned: number;
    exerciseDate?: string;
  }
) {
  const exerciseDate = data.exerciseDate
    ? new Date(data.exerciseDate)
    : new Date();

  const exercise = await prisma.exercise.create({
    data: {
      userId,
      name: data.name,
      durationMinutes: data.durationMinutes || 0,
      caloriesBurned: data.caloriesBurned,
      exerciseDate,
    },
  });

  // Sync daily summary (updates totalCaloriesBurned)
  await syncDailySummaryWithExercise(userId, exerciseDate);

  return exercise;
}

export async function deleteExercise(id: string) {
  const exercise = await prisma.exercise.findUnique({ where: { id } });
  if (!exercise) throw new Error("Exercise not found");

  await prisma.exercise.delete({ where: { id } });

  // Resync daily summary
  await syncDailySummaryWithExercise(exercise.userId, exercise.exerciseDate);

  return exercise;
}

/**
 * Recalculate totalCaloriesBurned in daily summary from
 * exercise entries + step calories for that day.
 */
async function syncDailySummaryWithExercise(userId: string, date: Date) {
  const dateOnly = new Date(date.toISOString().split("T")[0]);

  // Sum exercise calories for that day
  const exercises = await prisma.exercise.findMany({
    where: { userId, exerciseDate: dateOnly },
  });

  let exerciseCalories = 0;
  for (const ex of exercises) {
    exerciseCalories += ex.caloriesBurned;
  }

  // Also get step calories
  const stepsRecord = await prisma.dailyStep.findUnique({
    where: { userId_date: { userId, date: dateOnly } },
  });
  const stepCalories = stepsRecord?.caloriesBurned || 0;

  const totalCaloriesBurned =
    Math.round((exerciseCalories + stepCalories) * 100) / 100;

  // Upsert daily summary's totalCaloriesBurned field
  await prisma.dailySummary.upsert({
    where: { userId_date: { userId, date: dateOnly } },
    update: { totalCaloriesBurned },
    create: {
      userId,
      date: dateOnly,
      totalCaloriesBurned,
    },
  });
}
