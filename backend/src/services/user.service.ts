import prisma from "../prisma.js";
import { Prisma } from "../generated/prisma/client.js";

// Mifflin-St Jeor equation for BMR calculation
function calculateBMR(
  weightKg: number,
  heightCm: number,
  age: number,
  gender: string
): number {
  if (gender === "male") {
    return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
  } else {
    return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
  }
}

// Activity multipliers
function getActivityMultiplier(level: string): number {
  switch (level) {
    case "low":
      return 1.2;
    case "moderate":
      return 1.55;
    case "high":
      return 1.725;
    default:
      return 1.2;
  }
}

// Goal adjustments
function getGoalAdjustment(goal: string): number {
  switch (goal) {
    case "lose":
      return -500; // 500 calorie deficit
    case "gain":
      return 500; // 500 calorie surplus
    case "maintain":
    default:
      return 0;
  }
}

export function calculateTargetCalories(
  weightKg: number,
  heightCm: number,
  age: number,
  gender: string,
  activityLevel: string,
  goal: string
): number {
  const bmr = calculateBMR(weightKg, heightCm, age, gender);
  const tdee = bmr * getActivityMultiplier(activityLevel);
  return Math.round(tdee + getGoalAdjustment(goal));
}

export function calculateMacros(targetCalories: number) {
  // Standard macro split: 30% protein, 40% carbs, 30% fats
  return {
    targetProtein: Math.round((targetCalories * 0.3) / 4), // 4 cal/g protein
    targetCarbs: Math.round((targetCalories * 0.4) / 4), // 4 cal/g carbs
    targetFats: Math.round((targetCalories * 0.3) / 9), // 9 cal/g fats
  };
}

export async function createUser(data: Prisma.UserCreateInput) {
  const user = await prisma.user.create({ data });

  // If user has enough data, auto-create a goal
  if (
    user.weightKg &&
    user.heightCm &&
    user.age &&
    user.gender &&
    user.activityLevel &&
    user.goal
  ) {
    const targetCalories = calculateTargetCalories(
      user.weightKg,
      user.heightCm,
      user.age,
      user.gender,
      user.activityLevel,
      user.goal
    );
    const macros = calculateMacros(targetCalories);

    await prisma.userGoal.create({
      data: {
        userId: user.id,
        targetCalories,
        ...macros,
        isActive: true,
      },
    });

    // Also add initial weight to history
    await prisma.weightHistory.create({
      data: {
        userId: user.id,
        weightKg: user.weightKg,
      },
    });
  }

  return user;
}

export async function getUserById(id: string) {
  return prisma.user.findUnique({
    where: { id },
    include: {
      userGoals: { where: { isActive: true }, take: 1 },
    },
  });
}

export async function updateUser(id: string, data: Prisma.UserUpdateInput) {
  // Get current user to check if weight changed
  const currentUser = await prisma.user.findUnique({ where: { id } });
  if (!currentUser) throw new Error("User not found");

  const updatedUser = await prisma.user.update({ where: { id }, data });

  // If weight changed, insert weight history
  if (data.weightKg && data.weightKg !== currentUser.weightKg) {
    await prisma.weightHistory.create({
      data: {
        userId: id,
        weightKg: data.weightKg as number,
      },
    });
  }

  // Recalculate goals if relevant fields changed
  if (
    updatedUser.weightKg &&
    updatedUser.heightCm &&
    updatedUser.age &&
    updatedUser.gender &&
    updatedUser.activityLevel &&
    updatedUser.goal
  ) {
    const hasRelevantChange =
      data.weightKg || data.heightCm || data.age || data.activityLevel || data.goal;

    if (hasRelevantChange) {
      const targetCalories = calculateTargetCalories(
        updatedUser.weightKg,
        updatedUser.heightCm,
        updatedUser.age,
        updatedUser.gender,
        updatedUser.activityLevel,
        updatedUser.goal
      );
      const macros = calculateMacros(targetCalories);

      // Deactivate old goals
      await prisma.userGoal.updateMany({
        where: { userId: id, isActive: true },
        data: { isActive: false },
      });

      // Create new active goal
      await prisma.userGoal.create({
        data: {
          userId: id,
          targetCalories,
          ...macros,
          isActive: true,
        },
      });
    }
  }

  return updatedUser;
}

export async function deleteUser(id: string) {
  return prisma.user.delete({ where: { id } });
}
