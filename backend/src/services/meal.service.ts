import prisma from "../prisma.js";
import { syncDailySummary } from "./dailySummary.service.js";

export async function getUserMeals(
  userId: string,
  params: { date?: string; mealType?: string }
) {
  const where: any = { userId };

  if (params.date) {
    where.mealDate = new Date(params.date);
  }
  if (params.mealType) {
    where.mealType = params.mealType;
  }

  return prisma.meal.findMany({
    where,
    include: {
      items: {
        include: { food: true },
      },
    },
    orderBy: { consumedAt: "desc" },
  });
}

export async function getMealById(id: string) {
  return prisma.meal.findUnique({
    where: { id },
    include: {
      items: {
        include: { food: true },
      },
    },
  });
}

export async function createMeal(
  userId: string,
  data: {
    mealType: string;
    mealDate?: string;
    items?: { foodId: string; quantityGrams: number }[];
  }
) {
  const mealDate = data.mealDate ? new Date(data.mealDate) : new Date();

  const meal = await prisma.meal.create({
    data: {
      userId,
      mealType: data.mealType,
      mealDate,
      items: data.items
        ? {
            create: data.items.map((item) => ({
              foodId: item.foodId,
              quantityGrams: item.quantityGrams,
            })),
          }
        : undefined,
    },
    include: {
      items: {
        include: { food: true },
      },
    },
  });

  // Sync daily summary
  await syncDailySummary(userId, mealDate);

  return meal;
}

export async function updateMeal(
  id: string,
  data: { mealType?: string }
) {
  return prisma.meal.update({
    where: { id },
    data,
    include: {
      items: {
        include: { food: true },
      },
    },
  });
}

export async function deleteMeal(id: string) {
  const meal = await prisma.meal.findUnique({ where: { id } });
  if (!meal) throw new Error("Meal not found");

  await prisma.meal.delete({ where: { id } });

  // Resync daily summary
  await syncDailySummary(meal.userId, meal.mealDate);

  return meal;
}

export async function addMealItem(
  mealId: string,
  data: { foodId: string; quantityGrams: number }
) {
  const meal = await prisma.meal.findUnique({ where: { id: mealId } });
  if (!meal) throw new Error("Meal not found");

  const item = await prisma.mealItem.create({
    data: {
      mealId,
      foodId: data.foodId,
      quantityGrams: data.quantityGrams,
    },
    include: { food: true },
  });

  // Resync daily summary
  await syncDailySummary(meal.userId, meal.mealDate);

  return item;
}

export async function removeMealItem(id: string) {
  const item = await prisma.mealItem.findUnique({
    where: { id },
    include: { meal: true },
  });
  if (!item) throw new Error("Meal item not found");

  await prisma.mealItem.delete({ where: { id } });

  // Resync daily summary
  await syncDailySummary(item.meal.userId, item.meal.mealDate);

  return item;
}
