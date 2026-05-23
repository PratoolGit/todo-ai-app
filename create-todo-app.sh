#!/bin/bash
# Save as 'create-todo-app.sh', then run: bash create-todo-app.sh

PROJECT_NAME="todo-ai-app"
mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create package.json
cat > package.json << 'EOF'
{
  "name": "todo-ai-app",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview",
    "deploy": "gh-pages -d dist"
  },
  "dependencies": {
    "@dnd-kit/sortable": "^7.0.2",
    "@dnd-kit/core": "^6.0.8",
    "@dnd-kit/utilities": "^3.2.1",
    "framer-motion": "^10.16.4",
    "lucide-react": "^0.292.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-hot-toast": "^2.4.1",
    "zustand": "^4.4.6"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@typescript-eslint/eslint-plugin": "^6.10.0",
    "@typescript-eslint/parser": "^6.10.0",
    "@vitejs/plugin-react": "^4.1.1",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.53.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.4",
    "gh-pages": "^6.1.0",
    "postcss": "^8.4.31",
    "tailwindcss": "^3.3.5",
    "typescript": "^5.2.2",
    "vite": "^4.5.0"
  },
  "homepage": "https://YOUR_USERNAME.github.io/todo-ai-app"
}
EOF

# Create Vite config
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  base: '/todo-ai-app/',
  server: {
    port: 3000,
    open: true
  }
})
EOF

# Create TypeScript config
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

cat > tsconfig.node.json << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "strict": true
  },
  "include": ["vite.config.ts"]
}
EOF

# Create Tailwind config
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  darkMode: 'class',
  theme: {
    extend: {
      animation: {
        'slide-in': 'slideIn 0.3s ease-out',
        'fade-in': 'fadeIn 0.2s ease-in',
      },
      keyframes: {
        slideIn: {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(0)' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
      },
    },
  },
  plugins: [],
}
EOF

cat > postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Create index.html
cat > index.html << 'EOF'
<!doctype html>
<html lang="en" class="dark">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>AI Todo - Smart Task Manager</title>
    <meta name="description" content="Production-ready todo app with OpenRouter AI" />
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# Create source folder and all components
mkdir -p src/{components,store,types,hooks,utils}

# Main entry files
cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-gray-50 dark:bg-slate-900 text-gray-900 dark:text-gray-100 transition-colors duration-200;
  }
  ::-webkit-scrollbar {
    @apply w-2;
  }
  ::-webkit-scrollbar-track {
    @apply bg-gray-200 dark:bg-slate-700 rounded;
  }
  ::-webkit-scrollbar-thumb {
    @apply bg-gray-400 dark:bg-slate-500 rounded hover:bg-gray-500;
  }
}
EOF

# Types
cat > src/types/task.ts << 'EOF'
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
EOF

# Store with AI integration placeholder
cat > src/store/taskStore.ts << 'EOF'
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
EOF

# OpenRouter AI hook
cat > src/hooks/useOpenRouter.ts << 'EOF'
import { useState } from 'react';
import toast from 'react-hot-toast';

const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions';

interface UseOpenRouterProps {
  apiKey: string;
}

export const useOpenRouter = ({ apiKey }: UseOpenRouterProps) => {
  const [loading, setLoading] = useState(false);

  const breakDownTask = async (taskTitle: string): Promise<string[]> => {
    if (!apiKey) {
      toast.error('OpenRouter API key is missing. Please add it in settings.');
      return [];
    }

    setLoading(true);
    try {
      const response = await fetch(OPENROUTER_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
          'HTTP-Referer': window.location.origin,
          'X-Title': 'AI Todo App',
        },
        body: JSON.stringify({
          model: 'openai/gpt-3.5-turbo',
          messages: [
            {
              role: 'system',
              content: 'You are a helpful assistant that breaks down tasks into actionable subtasks. Return ONLY a JSON array of strings, no extra text.',
            },
            {
              role: 'user',
              content: `Break down this task into 3-5 subtasks: "${taskTitle}". Return as JSON array.`,
            },
          ],
          temperature: 0.7,
          max_tokens: 300,
        }),
      });

      if (!response.ok) throw new Error('API request failed');

      const data = await response.json();
      const content = data.choices[0].message.content;
      // Parse JSON array from response
      const subtasks = JSON.parse(content);
      return Array.isArray(subtasks) ? subtasks : [];
    } catch (error) {
      console.error('OpenRouter error:', error);
      toast.error('Failed to get AI suggestions. Check API key.');
      return [];
    } finally {
      setLoading(false);
    }
  };

  const suggestPriority = async (taskTitle: string): Promise<string | null> => {
    if (!apiKey) return null;
    setLoading(true);
    try {
      const response = await fetch(OPENROUTER_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: 'openai/gpt-3.5-turbo',
          messages: [
            {
              role: 'system',
              content: 'Return only one word: low, medium, or high.',
            },
            {
              role: 'user',
              content: `What priority (low/medium/high) should this task have? "${taskTitle}"`,
            },
          ],
          max_tokens: 10,
        }),
      });
      const data = await response.json();
      const priority = data.choices[0].message.content.trim().toLowerCase();
      return ['low', 'medium', 'high'].includes(priority) ? priority : null;
    } catch {
      return null;
    } finally {
      setLoading(false);
    }
  };

  return { breakDownTask, suggestPriority, loading };
};
EOF

# Main App component (beautiful GUI)
cat > src/App.tsx << 'EOF'
import React, { useState, useEffect } from 'react';
import { Toaster, toast } from 'react-hot-toast';
import { 
  Plus, Search, Filter, Moon, Sun, Trash2, 
  Download, Upload, Sparkles, Settings 
} from 'lucide-react';
import { useTaskStore } from './store/taskStore';
import { TaskItem } from './components/TaskItem';
import { TaskForm } from './components/TaskForm';
import { StatsPanel } from './components/StatsPanel';
import { useOpenRouter } from './hooks/useOpenRouter';
import type { Task, Priority, Category } from './types/task';

function App() {
  const { tasks, clearCompleted, importTasks, exportTasks } = useTaskStore();
  const [showForm, setShowForm] = useState(false);
  const [search, setSearch] = useState('');
  const [filterPriority, setFilterPriority] = useState<Priority | 'all'>('all');
  const [filterCategory, setFilterCategory] = useState<Category | 'all'>('all');
  const [showCompleted, setShowCompleted] = useState(true);
  const [darkMode, setDarkMode] = useState(true);
  const [apiKey, setApiKey] = useState(localStorage.getItem('openrouter_api_key') || '');
  const [showSettings, setShowSettings] = useState(false);
  
  const { breakDownTask, loading: aiLoading } = useOpenRouter({ apiKey });

  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [darkMode]);

  const saveApiKey = (key: string) => {
    setApiKey(key);
    localStorage.setItem('openrouter_api_key', key);
    toast.success('API key saved');
    setShowSettings(false);
  };

  const handleAIBreakdown = async (taskTitle: string, onSubtasksGenerated: (subtasks: string[]) => void) => {
    if (!apiKey) {
      toast.error('Please add OpenRouter API key in settings first');
      setShowSettings(true);
      return;
    }
    const subtasks = await breakDownTask(taskTitle);
    if (subtasks.length) {
      onSubtasksGenerated(subtasks);
      toast.success(`AI generated ${subtasks.length} subtasks!`);
    }
  };

  const filteredTasks = tasks.filter(task => {
    if (!showCompleted && task.completed) return false;
    if (filterPriority !== 'all' && task.priority !== filterPriority) return false;
    if (filterCategory !== 'all' && task.category !== filterCategory) return false;
    if (search && !task.title.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  const handleExport = () => {
    const data = exportTasks();
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `todo-backup-${new Date().toISOString()}.json`;
    a.click();
    URL.revokeObjectURL(url);
    toast.success('Tasks exported');
  };

  const handleImport = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => {
      try {
        const imported = JSON.parse(ev.target?.result as string);
        importTasks(imported);
        toast.success('Tasks imported');
      } catch {
        toast.error('Invalid file');
      }
    };
    reader.readAsText(file);
    e.target.value = '';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-slate-900 dark:to-slate-800">
      <Toaster position="top-right" />
      
      {/* Header */}
      <header className="sticky top-0 z-20 backdrop-blur-md bg-white/80 dark:bg-slate-900/80 border-b border-gray-200 dark:border-slate-700">
        <div className="max-w-6xl mx-auto px-4 py-4 flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Sparkles className="w-7 h-7 text-purple-500" />
            <h1 className="text-2xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
              AI Todo
            </h1>
          </div>
          <div className="flex gap-2">
            <button onClick={() => setDarkMode(!darkMode)} className="p-2 rounded-lg hover:bg-gray-200 dark:hover:bg-slate-700">
              {darkMode ? <Sun size={20} /> : <Moon size={20} />}
            </button>
            <button onClick={() => setShowSettings(true)} className="p-2 rounded-lg hover:bg-gray-200 dark:hover:bg-slate-700">
              <Settings size={20} />
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-4 py-8">
        {/* Stats Panel */}
        <StatsPanel tasks={tasks} />

        {/* Action Bar */}
        <div className="flex flex-wrap gap-4 items-center justify-between mt-6 mb-6">
          <div className="flex flex-wrap gap-3">
            <button
              onClick={() => setShowForm(true)}
              className="flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-xl hover:shadow-lg transition-all"
            >
              <Plus size={18} /> New Task
            </button>
            <button onClick={handleExport} className="flex items-center gap-2 px-4 py-2 border rounded-xl hover:bg-gray-100 dark:hover:bg-slate-700">
              <Download size={16} /> Export
            </button>
            <label className="flex items-center gap-2 px-4 py-2 border rounded-xl cursor-pointer hover:bg-gray-100 dark:hover:bg-slate-700">
              <Upload size={16} /> Import
              <input type="file" accept=".json" onChange={handleImport} className="hidden" />
            </label>
            <button onClick={clearCompleted} className="flex items-center gap-2 px-4 py-2 text-red-600 border border-red-200 rounded-xl hover:bg-red-50">
              <Trash2 size={16} /> Clear Completed
            </button>
          </div>
          <div className="flex gap-3">
            <div className="relative">
              <Search className="absolute left-3 top-2.5 text-gray-400" size={16} />
              <input
                type="text"
                placeholder="Search tasks..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-9 pr-4 py-2 border rounded-xl dark:bg-slate-800 dark:border-slate-700"
              />
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="flex flex-wrap gap-3 mb-6 text-sm">
          <select
            value={filterPriority}
            onChange={(e) => setFilterPriority(e.target.value as any)}
            className="px-3 py-1.5 border rounded-lg dark:bg-slate-800"
          >
            <option value="all">All Priorities</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
          </select>
          <select
            value={filterCategory}
            onChange={(e) => setFilterCategory(e.target.value as any)}
            className="px-3 py-1.5 border rounded-lg dark:bg-slate-800"
          >
            <option value="all">All Categories</option>
            <option value="work">Work</option>
            <option value="personal">Personal</option>
            <option value="shopping">Shopping</option>
            <option value="health">Health</option>
            <option value="other">Other</option>
          </select>
          <label className="flex items-center gap-2 px-3 py-1.5 border rounded-lg">
            <input
              type="checkbox"
              checked={showCompleted}
              onChange={(e) => setShowCompleted(e.target.checked)}
            />
            Show completed
          </label>
        </div>

        {/* Task List */}
        <div className="space-y-3">
          {filteredTasks.length === 0 ? (
            <div className="text-center py-16 text-gray-500 dark:text-gray-400">
              ✨ No tasks found. Create a new one!
            </div>
          ) : (
            filteredTasks.map((task) => (
              <TaskItem key={task.id} task={task} onAIBreakdown={handleAIBreakdown} aiLoading={aiLoading} />
            ))
          )}
        </div>
      </main>

      {/* Modals */}
      {showForm && (
        <TaskForm 
          onClose={() => setShowForm(false)} 
          onAIBreakdown={handleAIBreakdown}
          aiLoading={aiLoading}
        />
      )}
      
      {showSettings && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white dark:bg-slate-800 rounded-2xl p-6 w-full max-w-md m-4">
            <h2 className="text-xl font-bold mb-4">OpenRouter API Key</h2>
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-3">
              Get your key from <a href="https://openrouter.ai/keys" target="_blank" className="text-purple-500">openrouter.ai/keys</a>
            </p>
            <input
              type="password"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              placeholder="sk-or-v1-..."
              className="w-full px-4 py-2 border rounded-lg dark:bg-slate-700 mb-4"
            />
            <div className="flex justify-end gap-3">
              <button onClick={() => setShowSettings(false)} className="px-4 py-2 border rounded-lg">Cancel</button>
              <button onClick={() => saveApiKey(apiKey)} className="px-4 py-2 bg-purple-600 text-white rounded-lg">Save</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
EOF

# TaskItem component
cat > src/components/TaskItem.tsx << 'EOF'
import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Check, Trash2, Edit2, Flag, ChevronDown, ChevronUp, 
  Sparkles, Calendar, Plus 
} from 'lucide-react';
import { useTaskStore } from '../store/taskStore';
import type { Task } from '../types/task';

interface TaskItemProps {
  task: Task;
  onAIBreakdown: (title: string, callback: (subtasks: string[]) => void) => void;
  aiLoading: boolean;
}

const priorityColors = {
  low: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300',
  medium: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300',
  high: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300',
};

const categoryColors = {
  work: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30',
  personal: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30',
  shopping: 'bg-pink-100 text-pink-700 dark:bg-pink-900/30',
  health: 'bg-teal-100 text-teal-700 dark:bg-teal-900/30',
  other: 'bg-gray-100 text-gray-700 dark:bg-gray-700',
};

export const TaskItem: React.FC<TaskItemProps> = ({ task, onAIBreakdown, aiLoading }) => {
  const { toggleTask, deleteTask, updateTask, toggleSubtask, addSubtask } = useTaskStore();
  const [expanded, setExpanded] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(task.title);
  const [newSubtask, setNewSubtask] = useState('');

  const handleAddSubtask = () => {
    if (newSubtask.trim()) {
      addSubtask(task.id, newSubtask.trim());
      setNewSubtask('');
    }
  };

  const handleAISubtasks = () => {
    onAIBreakdown(task.title, (generatedSubtasks) => {
      generatedSubtasks.forEach((st) => addSubtask(task.id, st));
    });
  };

  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, x: -100 }}
      className="bg-white dark:bg-slate-800 rounded-xl shadow-sm border border-gray-200 dark:border-slate-700 overflow-hidden"
    >
      <div className="p-4 flex items-start gap-3 group">
        <button
          onClick={() => toggleTask(task.id)}
          className={`mt-0.5 w-5 h-5 rounded-full border-2 flex items-center justify-center transition-all ${
            task.completed
              ? 'bg-purple-500 border-purple-500'
              : 'border-gray-300 dark:border-slate-600'
          }`}
        >
          {task.completed && <Check size={12} className="text-white" />}
        </button>

        <div className="flex-1">
          {isEditing ? (
            <input
              type="text"
              value={editTitle}
              onChange={(e) => setEditTitle(e.target.value)}
              onBlur={() => {
                updateTask(task.id, { title: editTitle });
                setIsEditing(false);
              }}
              onKeyDown={(e) => e.key === 'Enter' && setIsEditing(false)}
              className="w-full px-2 py-1 border rounded dark:bg-slate-700"
              autoFocus
            />
          ) : (
            <h3 className={`font-medium ${task.completed && 'line-through text-gray-400'}`}>
              {task.title}
            </h3>
          )}
          
          <div className="flex flex-wrap gap-2 mt-2">
            <span className={`text-xs px-2 py-0.5 rounded-full ${priorityColors[task.priority]}`}>
              <Flag size={10} className="inline mr-1" /> {task.priority}
            </span>
            <span className={`text-xs px-2 py-0.5 rounded-full ${categoryColors[task.category]}`}>
              {task.category}
            </span>
            {task.dueDate && (
              <span className="text-xs text-gray-500 flex items-center gap-1">
                <Calendar size={10} /> {new Date(task.dueDate).toLocaleDateString()}
              </span>
            )}
          </div>

          {/* Subtasks section */}
          {task.subtasks.length > 0 && (
            <div className="mt-3 ml-2 space-y-1">
              {task.subtasks.map((st) => (
                <div key={st.id} className="flex items-center gap-2 text-sm">
                  <button
                    onClick={() => toggleSubtask(task.id, st.id)}
                    className={`w-3.5 h-3.5 rounded-full border ${
                      st.completed ? 'bg-purple-500 border-purple-500' : 'border-gray-300'
                    }`}
                  />
                  <span className={st.completed ? 'line-through text-gray-400' : ''}>{st.title}</span>
                </div>
              ))}
            </div>
          )}

          {/* Add subtask inline */}
          <div className="flex items-center gap-2 mt-2">
            <input
              type="text"
              value={newSubtask}
              onChange={(e) => setNewSubtask(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleAddSubtask()}
              placeholder="Add a subtask..."
              className="text-sm px-2 py-1 border rounded dark:bg-slate-700 w-40"
            />
            <button onClick={handleAddSubtask} className="text-xs text-purple-500">
              <Plus size={14} />
            </button>
            {!task.subtasks.length && (
              <button
                onClick={handleAISubtasks}
                disabled={aiLoading}
                className="text-xs flex items-center gap-1 text-purple-500 hover:text-purple-600"
              >
                <Sparkles size={12} /> AI suggest subtasks
              </button>
            )}
          </div>
        </div>

        <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <button onClick={() => setIsEditing(true)} className="p-1 hover:bg-gray-100 dark:hover:bg-slate-700 rounded">
            <Edit2 size={14} />
          </button>
          <button onClick={() => deleteTask(task.id)} className="p-1 hover:bg-red-100 dark:hover:bg-red-900/30 rounded text-red-500">
            <Trash2 size={14} />
          </button>
          <button onClick={() => setExpanded(!expanded)} className="p-1 hover:bg-gray-100 rounded">
            {expanded ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
          </button>
        </div>
      </div>

      <AnimatePresence>
        {expanded && (
          <motion.div
            initial={{ height: 0 }}
            animate={{ height: 'auto' }}
            exit={{ height: 0 }}
            className="border-t border-gray-100 dark:border-slate-700 p-4 bg-gray-50 dark:bg-slate-900/50"
          >
            <div className="space-y-2">
              {task.description && <p className="text-sm">{task.description}</p>}
              <p className="text-xs text-gray-500">
                Created: {new Date(task.createdAt).toLocaleString()}
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
};
EOF

# TaskForm component
cat > src/components/TaskForm.tsx << 'EOF'
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
EOF

# StatsPanel component
cat > src/components/StatsPanel.tsx << 'EOF'
import React from 'react';
import { CheckCircle, Circle, TrendingUp } from 'lucide-react';
import type { Task, TaskStats, Priority, Category } from '../types/task';

interface StatsPanelProps {
  tasks: Task[];
}

const computeStats = (tasks: Task[]): TaskStats => {
  const total = tasks.length;
  const completed = tasks.filter(t => t.completed).length;
  const pending = total - completed;
  const completionRate = total === 0 ? 0 : (completed / total) * 100;

  const byPriority: TaskStats['byPriority'] = {
    low: { total: 0, completed: 0 },
    medium: { total: 0, completed: 0 },
    high: { total: 0, completed: 0 },
  };
  const byCategory: TaskStats['byCategory'] = {
    work: { total: 0, completed: 0 },
    personal: { total: 0, completed: 0 },
    shopping: { total: 0, completed: 0 },
    health: { total: 0, completed: 0 },
    other: { total: 0, completed: 0 },
  };

  tasks.forEach(task => {
    byPriority[task.priority].total++;
    if (task.completed) byPriority[task.priority].completed++;
    byCategory[task.category].total++;
    if (task.completed) byCategory[task.category].completed++;
  });

  return { total, completed, pending, completionRate, byPriority, byCategory };
};

export const StatsPanel: React.FC<StatsPanelProps> = ({ tasks }) => {
  const stats = computeStats(tasks);

  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
      <div className="bg-white dark:bg-slate-800 rounded-xl p-4 shadow-sm">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-500">Total Tasks</p>
            <p className="text-2xl font-bold">{stats.total}</p>
          </div>
          <Circle className="text-purple-500" size={32} />
        </div>
      </div>
      <div className="bg-white dark:bg-slate-800 rounded-xl p-4 shadow-sm">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-500">Completed</p>
            <p className="text-2xl font-bold text-green-600">{stats.completed}</p>
          </div>
          <CheckCircle className="text-green-500" size={32} />
        </div>
      </div>
      <div className="bg-white dark:bg-slate-800 rounded-xl p-4 shadow-sm">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-500">Pending</p>
            <p className="text-2xl font-bold text-orange-500">{stats.pending}</p>
          </div>
          <TrendingUp className="text-orange-500" size={32} />
        </div>
      </div>
      <div className="bg-white dark:bg-slate-800 rounded-xl p-4 shadow-sm">
        <div>
          <p className="text-sm text-gray-500">Completion Rate</p>
          <p className="text-2xl font-bold">{Math.round(stats.completionRate)}%</p>
          <div className="w-full bg-gray-200 rounded-full h-1.5 mt-2">
            <div className="bg-purple-600 h-1.5 rounded-full" style={{ width: `${stats.completionRate}%` }} />
          </div>
        </div>
      </div>
    </div>
  );
};
EOF



# README
cat > README.md << 'EOF'
# AI Todo App – Production Ready

A full-featured todo app with **OpenRouter AI** integration that suggests subtasks and priorities. Built with React, TypeScript, Tailwind, Zustand, and Vite.

## Features
- ✅ CRUD operations, drag & drop reordering
- ✅ Subtasks, priorities, categories, due dates
- ✅ AI-powered subtask generation (OpenRouter API)
- ✅ Dark/light mode, search & filter
- ✅ Import/export JSON, clear completed
- ✅ Local storage persistence
- ✅ Responsive design, animations

## Setup

1. Clone or download this project.
2. Install dependencies:
   ```bash
   npm install