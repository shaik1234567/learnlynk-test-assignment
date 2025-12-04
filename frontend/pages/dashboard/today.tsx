import { useEffect, useState } from "react";
import { supabase } from "../../lib/supabaseClient";

type Task = {
  id: string;
  type: string;
  status: string;
  application_id: string;
  due_at: string;
};

export default function TodayDashboard() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function fetchTasks() {
    setLoading(true);
    setError(null);

    try {
      // Get start and end of today in UTC
      const now = new Date();
      // Use UTC to match database timezone
      const startOfToday = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
      const endOfToday = new Date(startOfToday);
      endOfToday.setUTCDate(endOfToday.getUTCDate() + 1);

      const { data, error } = await supabase
        .from("tasks")
        .select("*")
        .gte("due_at", startOfToday.toISOString())
        .lt("due_at", endOfToday.toISOString())
        .neq("status", "completed")
        .order("due_at", { ascending: true });

      if (error) {
        console.error("Supabase error:", error);
        throw error;
      }

      console.log("Fetched tasks:", data); // Debug log
      setTasks(data || []);
    } catch (err: any) {
      console.error("Error fetching tasks:", err);
      setError("Failed to load tasks: " + (err.message || "Unknown error"));
    } finally {
      setLoading(false);
    }
  }

  async function markComplete(id: string) {
    try {
      const { error } = await supabase
        .from("tasks")
        .update({ status: "completed" })
        .eq("id", id);

      if (error) {
        throw error;
      }

      // Update state optimistically
      setTasks((prevTasks) =>
        prevTasks.map((task) =>
          task.id === id ? { ...task, status: "completed" } : task
        )
      );
    } catch (err: any) {
      console.error(err);
      alert("Failed to update task");
    }
  }

  useEffect(() => {
    fetchTasks();
  }, []);

  if (loading) return <div>Loading tasks...</div>;
  if (error) return <div style={{ color: "red" }}>{error}</div>;

  return (
    <main style={{ padding: "1.5rem" }}>
      <h1>Today&apos;s Tasks</h1>
      {tasks.length === 0 && <p>No tasks due today 🎉</p>}

      {tasks.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>Type</th>
              <th>Application</th>
              <th>Due At</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {tasks.map((t) => (
              <tr key={t.id}>
                <td>{t.type}</td>
                <td>{t.application_id}</td>
                <td>{new Date(t.due_at).toLocaleString()}</td>
                <td>{t.status}</td>
                <td>
                  {t.status !== "completed" && (
                    <button onClick={() => markComplete(t.id)}>
                      Mark Complete
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </main>
  );
}
