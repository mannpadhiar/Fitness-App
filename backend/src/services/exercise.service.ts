import prisma from "../prisma.js";

/**
 * Normalize a date string (YYYY-MM-DD) or Date to a UTC midnight Date.
 * This ensures consistent matching with Prisma's @db.Date columns.
 */
function toDateOnly(input: string | Date): Date {
  if (typeof input === "string") {
    // "2026-04-06" → UTC midnight: 2026-04-06T00:00:00.000Z
    const parts = input.split("T")[0]; // strip any time component
    return new Date(parts + "T00:00:00.000Z");
  }
  // If already a Date, strip time
  const iso = input.toISOString().split("T")[0];
  return new Date(iso + "T00:00:00.000Z");
}

export async function getUserExercises(
  userId: string,
  params: { date?: string }
) {
  const where: any = { userId };

  if (params.date) {
    where.exerciseDate = toDateOnly(params.date);
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
  // Normalize to UTC midnight date-only
  const exerciseDate = data.exerciseDate
    ? toDateOnly(data.exerciseDate)
    : toDateOnly(new Date());

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
  const dateOnly = toDateOnly(date);

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
