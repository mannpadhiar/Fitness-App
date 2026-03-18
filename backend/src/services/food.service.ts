import prisma from "../prisma.js";
import { Prisma } from "../generated/prisma/client.js";

export async function searchFoods(params: {
  search?: string;
  source?: string;
  page?: number;
  limit?: number;
}) {
  const { search, source, page = 1, limit = 20 } = params;
  const where: Prisma.FoodWhereInput = {};

  if (search) {
    where.name = { contains: search, mode: "insensitive" };
  }
  if (source) {
    where.source = source;
  }

  const [foods, total] = await Promise.all([
    prisma.food.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { name: "asc" },
    }),
    prisma.food.count({ where }),
  ]);

  return { foods, total, page, limit, totalPages: Math.ceil(total / limit) };
}

export async function getFoodById(id: string) {
  return prisma.food.findUnique({ where: { id } });
}

export async function createFood(data: Prisma.FoodCreateInput) {
  return prisma.food.create({ data });
}

export async function updateFood(id: string, data: Prisma.FoodUpdateInput) {
  return prisma.food.update({ where: { id }, data });
}

export async function deleteFood(id: string) {
  return prisma.food.delete({ where: { id } });
}
