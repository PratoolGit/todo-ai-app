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
