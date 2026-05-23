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
