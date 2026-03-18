import prisma from "../prisma.js";
import { Prisma } from "../generated/prisma/client.js";

export async function getUserGoals(userId: string, activeOnly: boolean = false) {
  const where: Prisma.UserGoalWhereInput = { userId };
  if (activeOnly) where.isActive = true;

  return prisma.userGoal.findMany({
    where,
    orderBy: { createdAt: "desc" },
  });
}

export async function createUserGoal(
  userId: string,
  data: {
    targetCalories?: number;
    targetProtein?: number;
    targetCarbs?: number;
    targetFats?: number;
  }
) {
  // Deactivate all previous goals
  await prisma.userGoal.updateMany({
    where: { userId, isActive: true },
    data: { isActive: false },
  });

  return prisma.userGoal.create({
    data: {
      userId,
      ...data,
      isActive: true,
    },
  });
}

export async function updateUserGoal(
  id: string,
  data: {
    targetCalories?: number;
    targetProtein?: number;
    targetCarbs?: number;
    targetFats?: number;
  }
) {
  return prisma.userGoal.update({
    where: { id },
    data,
  });
}
