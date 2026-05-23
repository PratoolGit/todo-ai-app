import React, { useState } from 'react';
import { X, Sparkles } from 'lucide-react';
import { useTaskStore } from '../store/taskStore';
import type { Priority, Category } from '../types/task';

interface TaskFormProps {
  onClose: () => void;
  onAIBreakdown: (title: string, callback: (subtasks: string[]) => void) => void;
  aiLoading: boolean;
}

export const TaskForm: React.FC<TaskFormProps> = ({ onClose, onAIBreakdown, aiLoading }) => {
  const addTask = useTaskStore((state) => state.addTask);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState<Priority>('medium');
  const [category, setCategory] = useState<Category>('personal');
  const [dueDate, setDueDate] = useState('');
  const [useAI, setUseAI] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;
    addTask({
      title: title.trim(),
      description: description.trim() || undefined,
      priority,
      category,
      dueDate: dueDate ? new Date(dueDate) : undefined,
      completed: false,
    });
    onClose();
  };

  const handleAISuggest = async () => {
    if (!title.trim()) return;
    onAIBreakdown(title, (subtasks) => {
      // Add task with AI-generated subtasks
      addTask({
        title: title.trim(),
        description: description.trim() || undefined,
        priority,
        category,
        dueDate: dueDate ? new Date(dueDate) : undefined,
        completed: false,
        subtasks: subtasks.map((st) => ({ id: crypto.randomUUID(), title: st, completed: false })),
      });
      onClose();
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
      <div className="bg-white dark:bg-slate-800 rounded-2xl w-full max-w-md p-6 shadow-xl animate-fade-in">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">New Task</h2>
          <button onClick={onClose} className="p-1 hover:bg-gray-100 dark:hover:bg-slate-700 rounded">
            <X size={20} />
          </button>
        </div>
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Task title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg dark:bg-slate-700 dark:border-slate-600 mb-3"
            required
            autoFocus
          />
          <textarea
            placeholder="Description (optional)"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg dark:bg-slate-700 mb-3"
            rows={2}
          />
          <div className="grid grid-cols-2 gap-3 mb-3">
            <select
              value={priority}
              onChange={(e) => setPriority(e.target.value as Priority)}
              className="px-3 py-2 border rounded-lg dark:bg-slate-700"
            >
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value as Category)}
              className="px-3 py-2 border rounded-lg dark:bg-slate-700"
            >
              <option value="work">Work</option>
              <option value="personal">Personal</option>
              <option value="shopping">Shopping</option>
              <option value="health">Health</option>
              <option value="other">Other</option>
            </select>
          </div>
          <input
            type="date"
            value={dueDate}
            onChange={(e) => setDueDate(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg dark:bg-slate-700 mb-4"
          />
          <div className="flex gap-3">
            <button
              type="submit"
              className="flex-1 bg-purple-600 text-white py-2 rounded-lg hover:bg-purple-700"
            >
              Add Task
            </button>
            <button
              type="button"
              onClick={handleAISuggest}
              disabled={aiLoading || !title}
              className="flex items-center justify-center gap-2 flex-1 border border-purple-500 text-purple-600 py-2 rounded-lg hover:bg-purple-50 disabled:opacity-50"
            >
              <Sparkles size={16} /> {aiLoading ? 'Thinking...' : 'AI Subtasks'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
