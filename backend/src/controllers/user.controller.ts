import { Request, Response } from "express";
import * as userService from "../services/user.service.js";
import { createUserSchema, updateUserSchema } from "../validators/index.js";

export async function createUser(req: Request, res: Response) {
  try {
    const data = createUserSchema.parse(req.body);
    const user = await userService.createUser(data);
    res.status(201).json(user);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    if (error.code === "P2002") {
      res.status(409).json({ error: "User with this email already exists" });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function getUser(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const user = await userService.getUserById(id as string);
    if (!user) {
      res.status(404).json({ error: "User not found" });
      return;
    }
    res.json(user);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function updateUser(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const data = updateUserSchema.parse(req.body);
    const user = await userService.updateUser(id as string, data);
    res.json(user);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    if (error.message === "User not found") {
      res.status(404).json({ error: "User not found" });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function deleteUser(req: Request, res: Response) {
  try {
    const { id } = req.params;
    await userService.deleteUser(id as string);
    res.status(204).send();
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}
