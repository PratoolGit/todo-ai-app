export type Priority = 'low' | 'medium' | 'high';
export type Category = 'work' | 'personal' | 'shopping' | 'health' | 'other';

export interface Subtask {
  id: string;
  title: string;
  completed: boolean;
}

export interface Task {
  id: string;
  title: string;
  description?: string;
  completed: boolean;
  priority: Priority;
  category: Category;
  dueDate?: Date;
  createdAt: Date;
  subtasks: Subtask[];
  tags?: string[];
}

export interface TaskStats {
  total: number;
  completed: number;
  pending: number;
  completionRate: number;
  byPriority: Record<Priority, { total: number; completed: number }>;
  byCategory: Record<Category, { total: number; completed: number }>;
}
