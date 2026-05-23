import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Task, Priority, Category, Subtask } from '../types/task';

interface TaskStore {
  tasks: Task[];
  addTask: (task: Omit<Task, 'id' | 'createdAt' | 'subtasks'> & { subtasks?: Subtask[] }) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  updateTask: (id: string, updates: Partial<Task>) => void;
  reorderTasks: (oldIndex: number, newIndex: number) => void;
  toggleSubtask: (taskId: string, subtaskId: string) => void;
  addSubtask: (taskId: string, title: string) => void;
  clearCompleted: () => void;
  importTasks: (tasks: Task[]) => void;
  exportTasks: () => Task[];
}

export const useTaskStore = create<TaskStore>()(
  persist(
    (set, get) => ({
      tasks: [],
      addTask: (task) =>
        set((state) => ({
          tasks: [
            {
              ...task,
              id: crypto.randomUUID(),
              createdAt: new Date(),
              subtasks: task.subtasks || [],
            },
            ...state.tasks,
          ],
        })),
      toggleTask: (id) =>
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === id ? { ...task, completed: !task.completed } : task
          ),
        })),
      deleteTask: (id) =>
        set((state) => ({
          tasks: state.tasks.filter((task) => task.id !== id),
        })),
      updateTask: (id, updates) =>
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === id ? { ...task, ...updates } : task
          ),
        })),
      reorderTasks: (oldIndex, newIndex) =>
        set((state) => {
          const newTasks = [...state.tasks];
          const [moved] = newTasks.splice(oldIndex, 1);
          newTasks.splice(newIndex, 0, moved);
          return { tasks: newTasks };
        }),
      toggleSubtask: (taskId, subtaskId) =>
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === taskId
              ? {
                  ...task,
                  subtasks: task.subtasks.map((st) =>
                    st.id === subtaskId ? { ...st, completed: !st.completed } : st
                  ),
                }
              : task
          ),
        })),
      addSubtask: (taskId, title) =>
        set((state) => ({
          tasks: state.tasks.map((task) =>
            task.id === taskId
              ? {
                  ...task,
                  subtasks: [
                    ...task.subtasks,
                    { id: crypto.randomUUID(), title, completed: false },
                  ],
                }
              : task
          ),
        })),
      clearCompleted: () =>
        set((state) => ({
          tasks: state.tasks.filter((task) => !task.completed),
        })),
      importTasks: (tasks) => set({ tasks }),
      exportTasks: () => get().tasks,
    }),
    {
      name: 'ai-todo-storage',
    }
  )
);
