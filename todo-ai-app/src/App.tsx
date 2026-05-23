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
