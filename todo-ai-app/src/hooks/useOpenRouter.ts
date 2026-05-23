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
          model: 'openai/gpt-oss-120b:free',
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
