import prisma from "../prisma.js";

export async function syncDailySummary(userId: string, date: Date) {
  // Normalize date to start of day
  const dateOnly = new Date(date.toISOString().split("T")[0]);

  // Calculate totals from all meals on that date
  const meals = await prisma.meal.findMany({
    where: { userId, mealDate: dateOnly },
    include: {
      items: {
        include: { food: true },
      },
    },
  });

  let totalCaloriesConsumed = 0;
  let totalProtein = 0;
  let totalCarbs = 0;
  let totalFats = 0;

  for (const meal of meals) {
    for (const item of meal.items) {
      const ratio = item.quantityGrams / 100;
      totalCaloriesConsumed += (item.food.caloriesPer100g || 0) * ratio;
      totalProtein += (item.food.proteinPer100g || 0) * ratio;
      totalCarbs += (item.food.carbsPer100g || 0) * ratio;
      totalFats += (item.food.fatsPer100g || 0) * ratio;
    }
  }

  // Get calories burned from steps
  const stepsRecord = await prisma.dailyStep.findUnique({
    where: { userId_date: { userId, date: dateOnly } },
  });
  const totalCaloriesBurned = stepsRecord?.caloriesBurned || 0;

  // Upsert daily summary
  return prisma.dailySummary.upsert({
    where: { userId_date: { userId, date: dateOnly } },
    update: {
      totalCaloriesConsumed: Math.round(totalCaloriesConsumed * 100) / 100,
      totalProtein: Math.round(totalProtein * 100) / 100,
      totalCarbs: Math.round(totalCarbs * 100) / 100,
      totalFats: Math.round(totalFats * 100) / 100,
      totalCaloriesBurned,
    },
    create: {
      userId,
      date: dateOnly,
      totalCaloriesConsumed: Math.round(totalCaloriesConsumed * 100) / 100,
      totalProtein: Math.round(totalProtein * 100) / 100,
      totalCarbs: Math.round(totalCarbs * 100) / 100,
      totalFats: Math.round(totalFats * 100) / 100,
      totalCaloriesBurned,
    },
  });
}

export async function getDailySummary(userId: string, date: string) {
  const dateOnly = new Date(date);
  return prisma.dailySummary.findUnique({
    where: { userId_date: { userId, date: dateOnly } },
  });
}

export async function getDailySummaryRange(
  userId: string,
  from: string,
  to: string
) {
  return prisma.dailySummary.findMany({
    where: {
      userId,
      date: {
        gte: new Date(from),
        lte: new Date(to),
      },
    },
    orderBy: { date: "desc" },
  });
}
