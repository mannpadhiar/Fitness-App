import prisma from "../prisma.js";

export async function getWeightHistory(userId: string) {
  return prisma.weightHistory.findMany({
    where: { userId },
    orderBy: { recordedAt: "desc" },
  });
}

export async function addWeightEntry(
  userId: string,
  weightKg: number,
  recordedAt?: string
) {
  const entry = await prisma.weightHistory.create({
    data: {
      userId,
      weightKg,
      recordedAt: recordedAt ? new Date(recordedAt) : new Date(),
    },
  });

  // Also update the user's current weight
  await prisma.user.update({
    where: { id: userId },
    data: { weightKg },
  });

  return entry;
}
