import { Request, Response } from "express";
import * as exerciseService from "../services/exercise.service.js";
import { createExerciseSchema } from "../validators/index.js";

export async function getUserExercises(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const exercises = await exerciseService.getUserExercises(userId as string, {
      date: req.query.date as string | undefined,
    });
    res.json(exercises);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createExercise(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const data = createExerciseSchema.parse(req.body);
    const exercise = await exerciseService.createExercise(
      userId as string,
      data
    );
    res.status(201).json(exercise);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res
        .status(400)
        .json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function deleteExercise(req: Request, res: Response) {
  try {
    const { id } = req.params;
    await exerciseService.deleteExercise(id as string);
    res.status(204).send();
  } catch (error: any) {
    if (error.message === "Exercise not found") {
      res.status(404).json({ error: "Exercise not found" });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}
