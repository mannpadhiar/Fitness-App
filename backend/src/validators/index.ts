import { z } from "zod";

export const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6).max(100),
  name: z.string().max(100).optional(),
});

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6).max(100),
  name: z.string().max(100).optional(),
  authId: z.string().uuid().optional(),
  age: z.number().int().min(1).max(119).optional(),
  gender: z.enum(["male", "female", "other"]).optional(),
  heightCm: z.number().positive().optional(),
  weightKg: z.number().positive().optional(),
  goal: z.enum(["lose", "maintain", "gain"]).optional(),
  activityLevel: z.enum(["low", "moderate", "high"]).optional(),
});

export const updateUserSchema = z.object({
  name: z.string().max(100).optional(),
  age: z.number().int().min(1).max(119).optional(),
  gender: z.enum(["male", "female", "other"]).optional(),
  heightCm: z.number().positive().optional(),
  weightKg: z.number().positive().optional(),
  goal: z.enum(["lose", "maintain", "gain"]).optional(),
  activityLevel: z.enum(["low", "moderate", "high"]).optional(),
});

export const createFoodSchema = z.object({
  name: z.string().max(150),
  caloriesPer100g: z.number().min(0).optional(),
  proteinPer100g: z.number().min(0).optional(),
  carbsPer100g: z.number().min(0).optional(),
  fatsPer100g: z.number().min(0).optional(),
  fiberPer100g: z.number().min(0).optional(),
  sodiumPer100g: z.number().min(0).optional(),
  sugarPer100g: z.number().min(0).optional(),
  barcode: z.string().max(50).optional(),
  source: z.enum(["system", "user", "ai"]).optional(),
  isVerified: z.boolean().optional(),
});

export const updateFoodSchema = createFoodSchema.partial();

export const createMealSchema = z.object({
  mealType: z.enum(["breakfast", "lunch", "dinner", "snack"]),
  mealDate: z.string().optional(), // ISO date string
  items: z
    .array(
      z.object({
        foodId: z.string().uuid(),
        quantityGrams: z.number().positive(),
      })
    )
    .optional(),
});

export const addMealItemSchema = z.object({
  foodId: z.string().uuid(),
  quantityGrams: z.number().positive(),
});

export const createGoalSchema = z.object({
  targetCalories: z.number().int().positive().optional(),
  targetProtein: z.number().min(0).optional(),
  targetCarbs: z.number().min(0).optional(),
  targetFats: z.number().min(0).optional(),
});

export const updateGoalSchema = createGoalSchema.partial();

export const upsertDailyStepsSchema = z.object({
  steps: z.number().int().min(0),
  date: z.string().optional(), // ISO date string
});

export const addWeightSchema = z.object({
  weightKg: z.number().positive(),
  recordedAt: z.string().optional(), // ISO date string
});

export const createExerciseSchema = z.object({
  name: z.string().max(150),
  durationMinutes: z.number().int().min(0).optional(),
  caloriesBurned: z.number().min(0),
  exerciseDate: z.string().optional(), // ISO date string
});
